import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/colors.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../shared/achraf.dart';
import '../../shared/widgets/achraf_card.dart';
import '../../shared/widgets/pill.dart';
import '../../shared/widgets/progress_bar.dart';
import '../../shared/widgets/streak_badge.dart';
import '../../shared/widgets/task_tile.dart';
import '../ai_coach/ai_coach_screen.dart';
import '../day_complete/day_complete_screen.dart';
import '../quiz/quiz_screen.dart';
import '../task_detail/task_detail_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(refreshCounterProvider); // trigger rebuild on changes

    final dayIdAsync = ref.watch(currentDayIdProvider);
    final stats = ref.watch(userStatsProvider);

    return dayIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (dayId) {
        final day = ref.watch(dayProvider(dayId));
        final words = ref.watch(wordsForDayProvider(dayId));
        final sentences = ref.watch(sentencesForDayProvider(dayId));
        final tasks = ref.watch(tasksForDayProvider(dayId));
        final taskStates = ref.watch(taskStatesForDayProvider(dayId));
        final dueByDay = ref.watch(dueCountByDayProvider);

        if (!day.hasValue ||
            !stats.hasValue ||
            !tasks.hasValue ||
            !taskStates.hasValue) {
          return const Center(child: CircularProgressIndicator());
        }

        final d = day.value!;
        final s = stats.value!;
        final ws = words.value ?? const <Word>[];
        final ss = sentences.value ?? const <Sentence>[];
        final ts = tasks.value ?? const <Task>[];
        final tStates = taskStates.value ?? const <int, TaskState>{};

        final doneCount =
            ts.where((t) => tStates[t.id]?.isDone == true).length;
        final totalCount = ts.length;
        final totalDue =
            (dueByDay.value ?? const <int, int>{}).values.fold<int>(0, (a, b) => a + b);

        final achrafMsg = Achraf.greet(
          userName: s.name,
          streak: s.currentStreak,
          dayId: dayId,
          doneTasks: doneCount,
          totalTasks: totalCount,
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            AchrafCard(message: achrafMsg),
            const SizedBox(height: 12),
            // Pills row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StreakBadge(streak: s.currentStreak),
                Pill(text: 'اليوم $dayId / 90'),
                Pill(
                  text: 'المستوى ${s.currentLevel}',
                  icon: Icons.emoji_events_outlined,
                  bg: AppColors.amberSoft,
                  fg: AppColors.amber,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ProgressCard(done: doneCount, total: totalCount),
            const SizedBox(height: 14),
            _LessonBanner(day: d, words: ws.length, sentences: ss.length),
            const SizedBox(height: 14),
            _SectionTitle('سول أشرف AI'),
            const SizedBox(height: 8),
            _ToolTile(
              icon: Icons.auto_awesome,
              iconBg: AppColors.amberSoft,
              iconColor: AppColors.amber,
              title: 'prompts جاهزة للـ ChatGPT / Claude',
              subtitle: 'انسخ، الصق، وقرا اليوم مع AI.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AiCoachScreen(dayId: dayId),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SectionTitle('مهام اليوم'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (int i = 0; i < ts.length; i++) ...[
                    if (i > 0)
                      const Divider(height: 0, indent: 14, endIndent: 14),
                    TaskTile(
                      label: ts[i].labelAr,
                      instructions: ts[i].instructionsAr,
                      minutes: ts[i].durationMin,
                      done: tStates[ts[i].id]?.isDone == true,
                      icon: _iconFor(ts[i].type),
                      onToggle: () => _toggle(context, ref, ts[i], dayId, !(tStates[ts[i].id]?.isDone ?? false)),
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TaskDetailScreen(
                            task: ts[i],
                            dayId: dayId,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionTitle('اختبار اليوم'),
            const SizedBox(height: 8),
            _ToolTile(
              icon: Icons.quiz_outlined,
              iconBg: const Color(0xFFE7E4F7),
              iconColor: const Color(0xFF5C4DA8),
              title: 'اختبار سريع — 9 أسئلة',
              subtitle: 'باش تتأكد فهمت كلمات و جمل اليوم.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizScreen(dayId: dayId),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SectionTitle('مراجعة'),
            const SizedBox(height: 8),
            _ToolTile(
              icon: Icons.refresh,
              iconBg: AppColors.primarySoft,
              iconColor: AppColors.primary,
              title: 'بطاقات مستحقة اليوم',
              subtitle: 'عدد البطاقات: $totalDue',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('اذهب إلى تبويب "مراجعة" بالأسفل')),
                );
              },
            ),
            const SizedBox(height: 14),
            _EmergencyButton(dayId: dayId),
          ],
        );
      },
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'vocabulary':
        return Icons.menu_book_outlined;
      case 'listening':
        return Icons.headphones_outlined;
      case 'shadowing':
        return Icons.record_voice_over;
      case 'speaking':
        return Icons.mic_none_outlined;
      case 'writing':
        return Icons.edit_outlined;
      case 'review':
        return Icons.refresh;
      default:
        return Icons.check_circle_outline;
    }
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, Task t, int dayId, bool done) async {
    final vocabRepo = ref.read(vocabRepoProvider);
    final dayRepo = ref.read(dayRepoProvider);
    final statsRepo = ref.read(statsRepoProvider);
    final srsRepo = ref.read(srsRepoProvider);

    await vocabRepo.setTaskDone(t.id, done);
    if (done) {
      await dayRepo.addMinutes(dayId, t.durationMin);
      // When the vocabulary task is completed, seed SRS for the day's words.
      if (t.type == 'vocabulary') {
        await srsRepo.seedWordsFromDay(dayId);
      }
    }

    // If all 6 are done, mark day completed + bump streak + level + show celebration.
    final states = await vocabRepo.taskStatesForDay(dayId);
    final tasks = await vocabRepo.tasksForDay(dayId);
    final allDone =
        tasks.every((tt) => states[tt.id]?.isDone == true);
    if (allDone && done) {
      await dayRepo.setDayCompleted(dayId);
      final words = await vocabRepo.wordsForDay(dayId);
      final minutesSum =
          tasks.fold<int>(0, (a, b) => a + b.durationMin);
      final stats = await statsRepo.bumpStreakOnDayComplete(minutesSum, words.length);
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => DayCompleteScreen(
                    dayId: dayId,
                    streak: stats.currentStreak,
                  )),
        );
      }
    }

    // Refresh.
    ref.invalidate(taskStatesForDayProvider(dayId));
    ref.invalidate(userStatsProvider);
    ref.invalidate(dueCountByDayProvider);
    ref.invalidate(dueCardsProvider);
    ref.invalidate(completedCountProvider);
    ref.invalidate(allDayStatesProvider);
    ref.read(refreshCounterProvider.notifier).state++;
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressCard({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final v = total == 0 ? 0.0 : done / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'تقدّم اليوم',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Spacer(),
                Text(
                  '$done من $total مهام',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressBar(value: v, height: 12),
          ],
        ),
      ),
    );
  }
}

class _LessonBanner extends StatelessWidget {
  final Day day;
  final int words;
  final int sentences;
  const _LessonBanner(
      {required this.day, required this.words, required this.sentences});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                Pill(text: 'المرحلة ${day.phaseId}'),
                Pill(text: 'الأسبوع ${day.weekNo}'),
                Pill(text: 'اليوم ${day.id}'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              day.titleAr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                day.topicEn,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.inkSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MiniChip(icon: Icons.menu_book_outlined, label: '$words كلمة'),
                const SizedBox(width: 8),
                _MiniChip(icon: Icons.chat_bubble_outline, label: '$sentences جملة'),
                const SizedBox(width: 8),
                _MiniChip(icon: Icons.timer_outlined, label: '${day.estMinutes} د'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.inkSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmergencyButton extends ConsumerWidget {
  final int dayId;
  const _EmergencyButton({required this.dayId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amberSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 0.5),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'يوم مزدحم؟',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.amber,
                  ),
                ),
                Text(
                  'جرّب وضع "5 دقائق فقط" للحفاظ على السلسلة.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await _doEmergency(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'تم تسجيل وضع 5 دقائق ✓ — راجع البطاقات لتحافظ على السلسلة.'),
                  ),
                );
              }
            },
            child: const Text('ابدأ',
                style: TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w800,
                )),
          ),
        ],
      ),
    );
  }

  Future<void> _doEmergency(WidgetRef ref) async {
    final vocabRepo = ref.read(vocabRepoProvider);
    final tasks = await vocabRepo.tasksForDay(dayId);
    // Mark vocabulary task done so SRS gets seeded; user can still
    // open task detail to finish the others later.
    final vocab = tasks.firstWhere((t) => t.type == 'vocabulary');
    await vocabRepo.setTaskDone(vocab.id, true);
    await ref.read(srsRepoProvider).seedWordsFromDay(dayId);
    ref.invalidate(taskStatesForDayProvider(dayId));
    ref.invalidate(dueCardsProvider);
    ref.invalidate(dueCountByDayProvider);
    ref.read(refreshCounterProvider.notifier).state++;
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ToolTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: AppColors.inkSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
