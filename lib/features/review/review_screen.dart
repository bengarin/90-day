import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/colors.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/srs_repo.dart';
import '../../shared/tts.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _showMeaning = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(refreshCounterProvider);
    final dueAsync = ref.watch(dueCardsProvider);
    final byDayAsync = ref.watch(dueCountByDayProvider);

    return dueAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (cards) {
        if (cards.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 64, color: AppColors.primary),
                  const SizedBox(height: 12),
                  const Text(
                    'لا توجد بطاقات للمراجعة اليوم!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'أنهِ مهمة الكلمات لليوم لكي تُضاف بطاقات جديدة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.inkSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        final current = cards.first;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'مراجعة (${cards.length} بطاقة)',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _BigCard(
                      word: current.word,
                      showMeaning: _showMeaning,
                      onSpeak: () => Tts.instance.speakEn(current.word.wordEn),
                    ),
                    const SizedBox(height: 14),
                    if (!_showMeaning)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              setState(() => _showMeaning = true),
                          child: const Text('أظهر المعنى'),
                        ),
                      )
                    else
                      _GradeButtons(
                        onGrade: (g) async {
                          await ref.read(srsRepoProvider).grade(current.card, g);
                          setState(() => _showMeaning = false);
                          ref.invalidate(dueCardsProvider);
                          ref.invalidate(dueCountByDayProvider);
                          ref.read(refreshCounterProvider.notifier).state++;
                        },
                      ),
                    const SizedBox(height: 24),
                    byDayAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (m) => _DueByDayList(byDay: m),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BigCard extends StatelessWidget {
  final Word word;
  final bool showMeaning;
  final VoidCallback onSpeak;
  const _BigCard({
    required this.word,
    required this.showMeaning,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                word.wordEn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (word.ipa.isNotEmpty)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '/${word.ipa}/',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.inkSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            IconButton(
              icon: const Icon(Icons.volume_up, color: AppColors.primary),
              iconSize: 32,
              onPressed: onSpeak,
            ),
            if (showMeaning) ...[
              const SizedBox(height: 8),
              Text(
                word.meaningAr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  word.exampleEn,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.ink),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                word.exampleAr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.inkSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GradeButtons extends StatelessWidget {
  final ValueChanged<SrsGrade> onGrade;
  const _GradeButtons({required this.onGrade});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _Btn(
                color: AppColors.coral,
                label: 'صعبة',
                onTap: () => onGrade(SrsGrade.hard))),
        const SizedBox(width: 8),
        Expanded(
            child: _Btn(
                color: AppColors.primary,
                label: 'جيدة',
                onTap: () => onGrade(SrsGrade.good))),
        const SizedBox(width: 8),
        Expanded(
            child: _Btn(
                color: AppColors.amber,
                label: 'سهلة',
                onTap: () => onGrade(SrsGrade.easy))),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _Btn({required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

class _DueByDayList extends StatelessWidget {
  final Map<int, int> byDay;
  const _DueByDayList({required this.byDay});

  @override
  Widget build(BuildContext context) {
    if (byDay.isEmpty) return const SizedBox.shrink();
    final entries = byDay.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('بطاقات مستحقة حسب اليوم',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                )),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in entries)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'اليوم ${e.key}: ${e.value}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
