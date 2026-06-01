import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/colors.dart';
import '../../data/providers.dart';
import '../../shared/widgets/achraf_card.dart';
import 'quiz_generator.dart';
import 'quiz_models.dart';

/// End-of-day quiz. 80%+ required to pass.
class QuizScreen extends ConsumerStatefulWidget {
  final int dayId;
  const QuizScreen({super.key, required this.dayId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  static const int passPercent = 80;

  List<QuizQuestion>? _questions;
  int _idx = 0;
  final Map<int, int> _chosen = {};
  final Map<int, String> _typed = {};
  final TextEditingController _fillCtrl = TextEditingController();
  bool _revealed = false;
  bool _finished = false;

  @override
  void dispose() {
    _fillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(wordsForDayProvider(widget.dayId));
    final sentencesAsync = ref.watch(sentencesForDayProvider(widget.dayId));

    if (!wordsAsync.hasValue || !sentencesAsync.hasValue) {
      return Scaffold(
        appBar: AppBar(title: const Text('اختبار اليوم')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final words = wordsAsync.value!;
    final sentences = sentencesAsync.value!;

    _questions ??= QuizGenerator(seed: widget.dayId).build(
      dayWords: words,
      daySentences: sentences,
    );

    final qs = _questions!;
    if (qs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('اختبار اليوم')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('ما كاينش بزاف ديال المحتوى لهاد اليوم باش نديرو quiz.'),
          ),
        ),
      );
    }

    if (_finished) {
      return _resultScreen(qs);
    }

    final q = qs[_idx];
    _fillCtrl.text = _typed[_idx] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار اليوم ${widget.dayId}'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_idx + 1) / qs.length,
            backgroundColor: AppColors.line,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text(
                  'سؤال ${_idx + 1} من ${qs.length}',
                  style: const TextStyle(
                    color: AppColors.inkSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _kindPill(q.kind),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _questionCard(q),
                const SizedBox(height: 14),
                if (q.kind == QuizKind.fillBlank)
                  _fillField(q)
                else
                  _optionsList(q),
                const SizedBox(height: 14),
                if (_revealed) _feedbackCard(q),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canAdvance(q) ? () => _next(q) : null,
                child: Text(_revealed
                    ? (_idx == qs.length - 1 ? 'شوف النتيجة' : 'التالي')
                    : 'تحقق'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionCard(QuizQuestion q) {
    final isEnglishPrompt = q.kind == QuizKind.multipleChoice ||
        q.kind == QuizKind.fillBlank;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Directionality(
              textDirection:
                  isEnglishPrompt ? TextDirection.ltr : TextDirection.rtl,
              child: Text(
                q.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (q.hint != null) ...[
              const SizedBox(height: 8),
              Text(
                q.hint!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.inkSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _optionsList(QuizQuestion q) {
    final chosen = _chosen[_idx];
    return Column(
      children: [
        for (int i = 0; i < q.options.length; i++) ...[
          _optionTile(q, i, chosen),
          if (i < q.options.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _optionTile(QuizQuestion q, int i, int? chosen) {
    final picked = chosen == i;
    Color border = AppColors.line;
    Color bg = AppColors.card;
    if (_revealed) {
      if (i == q.correctIndex) {
        border = AppColors.primary;
        bg = AppColors.primarySoft;
      } else if (picked) {
        border = AppColors.coral;
        bg = const Color(0xFFFCEBE3);
      }
    } else if (picked) {
      border = AppColors.primary;
      bg = AppColors.primarySoft;
    }

    final isEnglishOption = q.kind == QuizKind.translateAr;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _revealed
          ? null
          : () => setState(() => _chosen[_idx] = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: picked || _revealed ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                String.fromCharCode(0x0623 + i), // أ ب ت ث
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Directionality(
                textDirection: isEnglishOption
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: Text(
                  q.options[i],
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fillField(QuizQuestion q) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: TextField(
            controller: _fillCtrl,
            enabled: !_revealed,
            decoration: InputDecoration(
              hintText: 'اكتب الكلمة...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (v) => _typed[_idx] = v,
          ),
        ),
      ),
    );
  }

  Widget _feedbackCard(QuizQuestion q) {
    final correct = q.isCorrect(_chosen[_idx], _typed[_idx]);
    final correctText = q.kind == QuizKind.fillBlank
        ? (q.acceptedAnswer ?? '')
        : q.options[q.correctIndex];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: correct ? AppColors.primarySoft : const Color(0xFFFCEBE3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.cancel,
            color: correct ? AppColors.primary : AppColors.coral,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              correct
                  ? 'صحيح ✓'
                  : 'الجواب الصحيح: $correctText',
              style: TextStyle(
                color: correct ? AppColors.primary : AppColors.coral,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kindPill(QuizKind k) {
    final label = switch (k) {
      QuizKind.multipleChoice => 'اختر',
      QuizKind.fillBlank => 'املأ الفراغ',
      QuizKind.translateAr => 'ترجم',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.amberSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.amber,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  bool _canAdvance(QuizQuestion q) {
    if (_revealed) return true;
    if (q.kind == QuizKind.fillBlank) {
      return (_typed[_idx] ?? '').trim().isNotEmpty;
    }
    return _chosen[_idx] != null;
  }

  void _next(QuizQuestion q) {
    if (!_revealed) {
      setState(() => _revealed = true);
      return;
    }
    if (_idx == _questions!.length - 1) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _idx++;
      _revealed = false;
    });
  }

  Widget _resultScreen(List<QuizQuestion> qs) {
    int correct = 0;
    for (int i = 0; i < qs.length; i++) {
      if (qs[i].isCorrect(_chosen[i], _typed[i])) correct++;
    }
    final pct = (correct / qs.length * 100).round();
    final passed = pct >= passPercent;

    return Scaffold(
      appBar: AppBar(title: Text('نتيجة اختبار اليوم ${widget.dayId}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              passed ? '🏆' : '💪',
              style: const TextStyle(fontSize: 80),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '$pct%',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: passed ? AppColors.primary : AppColors.amber,
              ),
            ),
          ),
          Center(
            child: Text(
              '$correct من ${qs.length} صحيحة',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.inkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AchrafCard(
            message: passed
                ? 'برافو! دزتي الاختبار ($pct%). الكلمات الجداد ولات ديالك.'
                : 'قريب — وصلتي $pct%، خصك $passPercent% باش تدوز. عاود راجع الكلمات اللي غلطتي فيها وحاول مرة آخرى.',
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _questions = null;
                _idx = 0;
                _chosen.clear();
                _typed.clear();
                _revealed = false;
                _finished = false;
              });
            },
            child: const Text('عاود الاختبار'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(passed),
            child: const Text('رجع'),
          ),
        ],
      ),
    );
  }
}
