import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/colors.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../shared/widgets/achraf_card.dart';

/// Generates copy-paste prompts for ChatGPT / Claude / any AI based on
/// the day's topic, words, and sentences. The app does NOT teach —
/// it hands the user a ready-made prompt to drop into an AI chat.
class AiCoachScreen extends ConsumerWidget {
  final int dayId;
  const AiCoachScreen({super.key, required this.dayId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayAsync = ref.watch(dayProvider(dayId));
    final wordsAsync = ref.watch(wordsForDayProvider(dayId));
    final sentencesAsync = ref.watch(sentencesForDayProvider(dayId));
    final statsAsync = ref.watch(userStatsProvider);

    if (!dayAsync.hasValue ||
        !wordsAsync.hasValue ||
        !sentencesAsync.hasValue ||
        !statsAsync.hasValue) {
      return Scaffold(
        appBar: AppBar(title: const Text('سول أشرف AI')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final day = dayAsync.value!;
    final words = wordsAsync.value!;
    final sentences = sentencesAsync.value!;
    final stats = statsAsync.value!;
    final level = stats.currentLevel;
    final language = stats.language;

    final prompts = _buildPrompts(day, words, sentences, level, language);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سول أشرف AI'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AchrafCard(
            message:
                'نسخ شي prompt من تحت، الصقو فـ ChatGPT أو Claude، وغادي يقريك '
                'الدرس بالطريقة لي تناسبك. أنا غير كنوريك الطريق.',
          ),
          const SizedBox(height: 16),
          for (final p in prompts) ...[
            _PromptCard(prompt: p),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          _OpenAiButtons(),
        ],
      ),
    );
  }

  List<_Prompt> _buildPrompts(
    Day day,
    List<Word> words,
    List<Sentence> sentences,
    String level,
    String language,
  ) {
    final langAr = language == 'fr' ? 'الفرنسية' : 'الإنجليزية';
    final langEn = language == 'fr' ? 'French' : 'English';

    final wordList = words.map((w) => w.wordEn).join(', ');
    final wordsWithMeaning =
        words.map((w) => '- ${w.wordEn} = ${w.meaningAr}').join('\n');
    final sampleSentences =
        sentences.take(3).map((s) => '- ${s.sentenceEn}').join('\n');

    // Light-touch level hint embedded in each prompt so the AI calibrates.
    final levelHint = switch (level) {
      'A1' =>
        'مبتدئ تماماً: استعمل جمل قصار جدا (3-5 كلمات)، present simple فقط، مفردات أساسية.',
      'A2' =>
        'مبتدئ متقدم: جمل بسيطة، present + past simple، vocabulary للحياة اليومية.',
      'B1' =>
        'متوسط: جمل أطول، استعمل present perfect, past continuous, conditionals بسيطة.',
      'B2' =>
        'متوسط متقدم: قواعد أعقد، expressions اصطلاحية، لا تتجنب الـ phrasal verbs.',
      _ => '',
    };

    // For French learners, hint the AI to translate/adapt English content.
    final fromEnNote = language == 'fr'
        ? '\n\nملاحظة: الكلمات أعلاه بالإنجليزية فالتطبيق ديالي. ترجمهم/كيفهم للـ$langAr قبل ما تستعملهم فالأمثلة.'
        : '';

    return [
      _Prompt(
        title: 'علّمني الدرس',
        icon: Icons.school_outlined,
        body: '''أنا مغربي، كنتعلم $langAr ($langEn). المستوى ديالي: $level.
$levelHint

اليوم خاصني نتعلم الموضوع: "${day.topicEn}" (${day.topicAr}).

عرّفني هاد الموضوع بالدارجة، فبساطة:
1. شرح فـ 3-4 جمل قصار، بمثال من الحياة اليومية ديال شي مغربي.
2. 5 جمل بالـ$langAr بسيطة كتستعمل هاد الموضوع، مع الترجمة بالدارجة.
3. الأخطاء الشائعة لي كيدير المغاربة فهاد الباب.
4. تمرين قصير من 3 أسئلة باش نتأكد فهمت — انتظر جوابي قبل ما تكمل.

ابدا الجواب ديالك بالدارجة، وحاول تكون مختصر وواضح.''',
      ),
      _Prompt(
        title: 'علّمني هاد الكلمات',
        icon: Icons.menu_book_outlined,
        body: '''عندي ${words.length} كلمة اليوم خاصني نحفظهم. المستوى ديالي: $level.
$levelHint

الكلمات:
$wordsWithMeaning$fromEnNote

ساعدني نحفظهم بهاد الطريقة:
1. لكل كلمة، عطيني جملة بالـ$langAr بسيطة جدا (5-7 كلمات) كتستعملها فسياق طبيعي.
2. بعدها، عطيني الترجمة ديال الجملة بالدارجة.
3. فالأخر، عطيني hack صغير (mnemonics) لكل كلمة باش نحفظها بسرعة — استعمل تشابه فالصوت مع كلمة عربية أو دارجة.

كون قصير وواضح، بلا فلسفة.''',
      ),
      _Prompt(
        title: 'دير معايا محادثة',
        icon: Icons.chat_bubble_outline,
        body: '''أنا كنتعلم $langAr. المستوى ديالي: $level. الموضوع ديال اليوم: "${day.topicEn}".
$levelHint

تعال نديرو محادثة قصيرة بالـ$langAr فهاد الموضوع. قواعد:
- تبدا أنت بسؤال بسيط.
- استعمل غير الكلمات لي عند مستوى $level.
- منين نجاوب، صحح لي الأخطاء بطريقة لطيفة:
  * كتب الجواب ديالي معدّل
  * اشرح الخطأ بالدارجة فـ سطر واحد
- المحادثة كاملة كتكون فـ 6 questions/answers.

ابدا الآن.''',
      ),
      _Prompt(
        title: 'اختبرني',
        icon: Icons.quiz_outlined,
        body: '''أنا كنتعلم $langAr، المستوى $level. اليوم تعلمت الموضوع: "${day.topicEn}" مع هاد الكلمات: $wordList.
$levelHint

دير لي quiz بالـ$langAr من 5 أسئلة باش نتأكد فهمت:
- 2 multiple-choice (سؤال + 4 إجابات، وحدة صحيحة)
- 2 fill-in-the-blank (جملة فيها كلمة ناقصة، وأنا نكملها)
- 1 سؤال ديال الترجمة (دارجة → $langAr)

عطيني الأسئلة وحدة بوحدة. استنى الجواب ديالي، ثم قول لي صحيح/خطأ مع الشرح. فالأخر عطيني score من 5.''',
      ),
      _Prompt(
        title: 'دور هاد الجمل لحياتي',
        icon: Icons.format_quote_outlined,
        body: '''هاد الجمل (بالإنجليزية فالتطبيق ديالي):
$sampleSentences

دور كل وحدة فيهم باش تكون:
1. بالـ$langAr (ترجم/كيف إيلا كانوا بلغة أخرى)
2. مرتبطة بالحياة ديال شي شاب مغربي عادي (طالب أو خدام)
3. مناسبة للمستوى $level
$levelHint

اعطيني لكل جملة: النسخة الجديدة بالـ$langAr + الترجمة بالدارجة + 2 variations.''',
      ),
    ];
  }
}

class _Prompt {
  final String title;
  final IconData icon;
  final String body;
  const _Prompt({required this.title, required this.icon, required this.body});
}

class _PromptCard extends StatelessWidget {
  final _Prompt prompt;
  const _PromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(prompt.icon,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    prompt.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                prompt.body,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.ink,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: prompt.body));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم النسخ ✓'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('نسخ'),
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

class _OpenAiButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'بعد ما تنسخ، فتح:',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'افتح أي تطبيق AI، الصق الـ prompt، وقرا.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.inkSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _AppHint(emoji: '🤖', label: 'ChatGPT'),
                _AppHint(emoji: '🧠', label: 'Claude'),
                _AppHint(emoji: '✨', label: 'Gemini'),
                _AppHint(emoji: '🔮', label: 'Perplexity'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppHint extends StatelessWidget {
  final String emoji;
  final String label;
  const _AppHint({required this.emoji, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              )),
        ],
      ),
    );
  }
}
