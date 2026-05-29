import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/colors.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../shared/widgets/progress_bar.dart';
import '../settings/settings_screen.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(refreshCounterProvider);

    final dayIdAsync = ref.watch(currentDayIdProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final phasesAsync = ref.watch(allPhasesProvider);
    final dayStatesAsync = ref.watch(allDayStatesProvider);
    final completedAsync = ref.watch(completedCountProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: false,
          floating: true,
          title: const Text('التقدم'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _StatsGrid(
                stats: statsAsync.value,
                completed: completedAsync.value ?? 0,
              ),
              const SizedBox(height: 14),
              _LevelBadge(level: statsAsync.value?.currentLevel ?? 'A1'),
              const SizedBox(height: 14),
              _PhasesCard(
                phases: phasesAsync.value ?? const [],
                dayStates: dayStatesAsync.value ?? const {},
                currentDayId: dayIdAsync.value ?? 1,
              ),
              const SizedBox(height: 14),
              _CalendarCard(
                dayStates: dayStatesAsync.value ?? const {},
                currentDayId: dayIdAsync.value ?? 1,
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final UserStats? stats;
  final int completed;
  const _StatsGrid({required this.stats, required this.completed});

  @override
  Widget build(BuildContext context) {
    final pct = (completed / 90 * 100).round();
    final words = stats?.totalWords ?? 0;
    final hours = ((stats?.totalMinutes ?? 0) / 60).toStringAsFixed(1);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.7,
      children: [
        _StatCell(label: 'أيام مكتملة', value: '$completed / 90'),
        _StatCell(label: 'نسبة الإنجاز', value: '$pct%'),
        _StatCell(label: 'كلمات تمت دراستها', value: '$words'),
        _StatCell(label: 'ساعات التعلم', value: '$hours س'),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.amberSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events,
                  color: AppColors.amber, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('مستواك الحالي',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.inkSecondary,
                      )),
                  Text(
                    level,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'A1 → A2 → B1 → B2',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhasesCard extends StatelessWidget {
  final List<Phase> phases;
  final Map<int, DayState> dayStates;
  final int currentDayId;
  const _PhasesCard({
    required this.phases,
    required this.dayStates,
    required this.currentDayId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('المراحل الثلاث',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                )),
            const SizedBox(height: 10),
            for (final p in phases) ...[
              _PhaseRow(
                phase: p,
                dayStates: dayStates,
                currentDayId: currentDayId,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhaseRow extends StatelessWidget {
  final Phase phase;
  final Map<int, DayState> dayStates;
  final int currentDayId;
  const _PhaseRow({
    required this.phase,
    required this.dayStates,
    required this.currentDayId,
  });

  @override
  Widget build(BuildContext context) {
    final total = phase.dayEnd - phase.dayStart + 1;
    int done = 0;
    for (int d = phase.dayStart; d <= phase.dayEnd; d++) {
      if (dayStates[d]?.status == 'completed') done++;
    }
    final locked = currentDayId < phase.dayStart;
    final pct = done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              locked ? Icons.lock_outline : Icons.lock_open_outlined,
              size: 16,
              color: locked ? AppColors.inkSecondary : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                phase.nameAr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            Text(
              '$done / $total',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ProgressBar(
          value: pct,
          color: locked ? AppColors.inkSecondary : AppColors.primary,
        ),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final Map<int, DayState> dayStates;
  final int currentDayId;
  const _CalendarCard({
    required this.dayStates,
    required this.currentDayId,
  });

  @override
  Widget build(BuildContext context) {
    // Show 28 days centered around the current day.
    final start = (currentDayId - 14).clamp(1, 90 - 27);
    final days = List.generate(28, (i) => start + i);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('آخر 28 يوم',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                )),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, i) {
                final d = days[i];
                final st = dayStates[d]?.status;
                final isToday = d == currentDayId;
                final completed = st == 'completed';
                Color bg;
                Color fg;
                if (isToday) {
                  bg = AppColors.amberSoft;
                  fg = AppColors.amber;
                } else if (completed) {
                  bg = AppColors.primary;
                  fg = Colors.white;
                } else {
                  bg = AppColors.background;
                  fg = AppColors.inkSecondary;
                }
                return Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.line,
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$d',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
