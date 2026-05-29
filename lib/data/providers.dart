import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/date_utils.dart';
import 'models/models.dart';
import 'repositories/day_repo.dart';
import 'repositories/srs_repo.dart';
import 'repositories/stats_repo.dart';
import 'repositories/vocab_repo.dart';

// ----- repos as plain providers -----
final dayRepoProvider = Provider((_) => DayRepo());
final vocabRepoProvider = Provider((_) => VocabRepo());
final srsRepoProvider = Provider((_) => SrsRepo());
final statsRepoProvider = Provider((_) => StatsRepo());

// ----- current day id -----
/// The "today" day_id (1..90). Computed from the user's first_open_date
/// stored in settings. If not yet set, returns 1.
final currentDayIdProvider = FutureProvider<int>((ref) async {
  final stats = ref.read(statsRepoProvider);
  final firstOpen = await stats.getSetting('first_open_date');
  if (firstOpen == null) return 1;
  final start = parseDate(firstOpen);
  final diff = daysBetween(start, today());
  final d = diff + 1;
  if (d < 1) return 1;
  if (d > 90) return 90;
  return d;
});

// ----- per-day data -----
final dayProvider = FutureProvider.family<Day, int>((ref, id) async {
  return ref.read(dayRepoProvider).getDay(id);
});

final dayStateProvider =
    FutureProvider.family<DayState, int>((ref, id) async {
  return ref.read(dayRepoProvider).getDayState(id);
});

final wordsForDayProvider =
    FutureProvider.family<List<Word>, int>((ref, id) async {
  return ref.read(vocabRepoProvider).wordsForDay(id);
});

final sentencesForDayProvider =
    FutureProvider.family<List<Sentence>, int>((ref, id) async {
  return ref.read(vocabRepoProvider).sentencesForDay(id);
});

final tasksForDayProvider =
    FutureProvider.family<List<Task>, int>((ref, id) async {
  return ref.read(vocabRepoProvider).tasksForDay(id);
});

final taskStatesForDayProvider =
    FutureProvider.family<Map<int, TaskState>, int>((ref, id) async {
  return ref.read(vocabRepoProvider).taskStatesForDay(id);
});

// ----- stats -----
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  return ref.read(statsRepoProvider).get();
});

final allPhasesProvider = FutureProvider<List<Phase>>((ref) async {
  return ref.read(dayRepoProvider).allPhases();
});

final allDayStatesProvider = FutureProvider<Map<int, DayState>>((ref) async {
  return ref.read(dayRepoProvider).allDayStates();
});

final completedCountProvider = FutureProvider<int>((ref) async {
  return ref.read(statsRepoProvider).completedDayCount();
});

// ----- review (SRS) -----
final dueCardsProvider =
    FutureProvider<List<({SrsCard card, Word word})>>((ref) async {
  return ref.read(srsRepoProvider).dueToday();
});

final dueCountByDayProvider = FutureProvider<Map<int, int>>((ref) async {
  return ref.read(srsRepoProvider).dueCountByDay();
});

/// Bumps every time something changes (task done, srs graded, etc).
/// Watchers can listen to refresh.
final refreshCounterProvider = StateProvider<int>((ref) => 0);
