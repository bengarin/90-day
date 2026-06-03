/// Plain data models that mirror the SQLite rows.
/// Kept in a single file because the app stays simple.

class Phase {
  final int id;
  final String nameAr;
  final int dayStart;
  final int dayEnd;
  final String description;

  const Phase({
    required this.id,
    required this.nameAr,
    required this.dayStart,
    required this.dayEnd,
    required this.description,
  });

  factory Phase.fromMap(Map<String, dynamic> m) => Phase(
        id: m['id'] as int,
        nameAr: m['name_ar'] as String,
        dayStart: m['day_start'] as int,
        dayEnd: m['day_end'] as int,
        description: (m['description'] as String?) ?? '',
      );
}

class Day {
  final int id;
  final int phaseId;
  final int weekNo;
  final String titleAr;
  final String topicEn;
  final String topicAr;
  final int estMinutes;

  const Day({
    required this.id,
    required this.phaseId,
    required this.weekNo,
    required this.titleAr,
    required this.topicEn,
    required this.topicAr,
    required this.estMinutes,
  });

  factory Day.fromMap(Map<String, dynamic> m) => Day(
        id: m['id'] as int,
        phaseId: m['phase_id'] as int,
        weekNo: m['week_no'] as int,
        titleAr: m['title_ar'] as String,
        topicEn: m['topic_en'] as String,
        topicAr: m['topic_ar'] as String,
        estMinutes: m['est_minutes'] as int,
      );
}

class Word {
  final int id;
  final int dayId;
  final String wordEn;
  final String ipa;
  final String meaningAr;
  final String exampleEn;
  final String exampleAr;
  final String audioRef;

  const Word({
    required this.id,
    required this.dayId,
    required this.wordEn,
    required this.ipa,
    required this.meaningAr,
    required this.exampleEn,
    required this.exampleAr,
    required this.audioRef,
  });

  factory Word.fromMap(Map<String, dynamic> m) => Word(
        id: m['id'] as int,
        dayId: m['day_id'] as int,
        wordEn: m['word_en'] as String,
        ipa: (m['ipa'] as String?) ?? '',
        meaningAr: m['meaning_ar'] as String,
        exampleEn: (m['example_en'] as String?) ?? '',
        exampleAr: (m['example_ar'] as String?) ?? '',
        audioRef: (m['audio_ref'] as String?) ?? '',
      );
}

class Sentence {
  final int id;
  final int dayId;
  final String sentenceEn;
  final String translationAr;
  final String audioRef;

  const Sentence({
    required this.id,
    required this.dayId,
    required this.sentenceEn,
    required this.translationAr,
    required this.audioRef,
  });

  factory Sentence.fromMap(Map<String, dynamic> m) => Sentence(
        id: m['id'] as int,
        dayId: m['day_id'] as int,
        sentenceEn: m['sentence_en'] as String,
        translationAr: m['translation_ar'] as String,
        audioRef: (m['audio_ref'] as String?) ?? '',
      );
}

class Task {
  final int id;
  final int dayId;
  final String type; // vocabulary/listening/shadowing/speaking/writing/review
  final String labelAr;
  final String instructionsAr;
  final int durationMin;
  final int sortOrder;

  const Task({
    required this.id,
    required this.dayId,
    required this.type,
    required this.labelAr,
    required this.instructionsAr,
    required this.durationMin,
    required this.sortOrder,
  });

  factory Task.fromMap(Map<String, dynamic> m) => Task(
        id: m['id'] as int,
        dayId: m['day_id'] as int,
        type: m['type'] as String,
        labelAr: m['label_ar'] as String,
        instructionsAr: m['instructions_ar'] as String,
        durationMin: m['duration_min'] as int,
        sortOrder: m['sort_order'] as int,
      );
}

class UserStats {
  final int id;
  final String name;
  final String dailyGoal;
  final int currentStreak;
  final int longestStreak;
  final String? lastActiveDate; // yyyy-mm-dd
  final int totalMinutes;
  final int totalWords;
  final String currentLevel; // A1/A2/B1/B2
  final String language; // en / fr

  const UserStats({
    required this.id,
    required this.name,
    required this.dailyGoal,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
    required this.totalMinutes,
    required this.totalWords,
    required this.currentLevel,
    this.language = 'en',
  });

  factory UserStats.fromMap(Map<String, dynamic> m) => UserStats(
        id: m['id'] as int,
        name: (m['name'] as String?) ?? '',
        dailyGoal: (m['daily_goal'] as String?) ?? '',
        currentStreak: (m['current_streak'] as int?) ?? 0,
        longestStreak: (m['longest_streak'] as int?) ?? 0,
        lastActiveDate: m['last_active_date'] as String?,
        totalMinutes: (m['total_minutes'] as int?) ?? 0,
        totalWords: (m['total_words'] as int?) ?? 0,
        currentLevel: (m['current_level'] as String?) ?? 'A1',
        language: (m['language'] as String?) ?? 'en',
      );

  UserStats copyWith({
    String? name,
    String? dailyGoal,
    int? currentStreak,
    int? longestStreak,
    String? lastActiveDate,
    int? totalMinutes,
    int? totalWords,
    String? currentLevel,
    String? language,
  }) =>
      UserStats(
        id: id,
        name: name ?? this.name,
        dailyGoal: dailyGoal ?? this.dailyGoal,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
        totalMinutes: totalMinutes ?? this.totalMinutes,
        totalWords: totalWords ?? this.totalWords,
        currentLevel: currentLevel ?? this.currentLevel,
        language: language ?? this.language,
      );
}

class DayState {
  final int dayId;
  final String status; // locked | available | completed
  final String? completedAt;
  final int minutesSpent;

  const DayState({
    required this.dayId,
    required this.status,
    required this.completedAt,
    required this.minutesSpent,
  });

  factory DayState.fromMap(Map<String, dynamic> m) => DayState(
        dayId: m['day_id'] as int,
        status: m['status'] as String,
        completedAt: m['completed_at'] as String?,
        minutesSpent: (m['minutes_spent'] as int?) ?? 0,
      );
}

class TaskState {
  final int taskId;
  final int dayId;
  final bool isDone;
  final String? doneAt;

  const TaskState({
    required this.taskId,
    required this.dayId,
    required this.isDone,
    required this.doneAt,
  });

  factory TaskState.fromMap(Map<String, dynamic> m) => TaskState(
        taskId: m['task_id'] as int,
        dayId: m['day_id'] as int,
        isDone: (m['is_done'] as int? ?? 0) == 1,
        doneAt: m['done_at'] as String?,
      );
}

class SrsCard {
  final int wordId;
  final String nextReviewDate; // yyyy-mm-dd
  final String? lastReviewed;
  // FSRS-4.5 fields.
  final double stability;
  final double difficulty;
  final int state; // 0 new | 1 learning | 2 review | 3 relearning
  final int lapses;
  final int reps;
  final int elapsedDays;
  final int scheduledDays;

  const SrsCard({
    required this.wordId,
    required this.nextReviewDate,
    required this.lastReviewed,
    this.stability = 0,
    this.difficulty = 0,
    this.state = 0,
    this.lapses = 0,
    this.reps = 0,
    this.elapsedDays = 0,
    this.scheduledDays = 0,
  });

  factory SrsCard.fromMap(Map<String, dynamic> m) => SrsCard(
        wordId: m['word_id'] as int,
        nextReviewDate: m['next_review_date'] as String,
        lastReviewed: m['last_reviewed'] as String?,
        stability: ((m['stability'] as num?) ?? 0).toDouble(),
        difficulty: ((m['difficulty'] as num?) ?? 0).toDouble(),
        state: (m['state'] as int?) ?? 0,
        lapses: (m['lapses'] as int?) ?? 0,
        reps: (m['reps'] as int?) ?? 0,
        elapsedDays: (m['elapsed_days'] as int?) ?? 0,
        scheduledDays: (m['scheduled_days'] as int?) ?? 0,
      );
}
