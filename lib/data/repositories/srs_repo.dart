import 'package:sqflite/sqflite.dart';

import '../../core/date_utils.dart';
import '../database/db_helper.dart';
import '../models/models.dart';
import '../srs/fsrs.dart';

/// Grade values used by the Review screen buttons.
/// Maps directly to FSRS ratings (again=1, hard=2, good=3, easy=4).
enum SrsGrade { again, hard, good, easy }

int _gradeToRating(SrsGrade g) {
  switch (g) {
    case SrsGrade.again:
      return FsrsRating.again;
    case SrsGrade.hard:
      return FsrsRating.hard;
    case SrsGrade.good:
      return FsrsRating.good;
    case SrsGrade.easy:
      return FsrsRating.easy;
  }
}

FsrsCard _toFsrs(SrsCard c) {
  final last = c.lastReviewed == null ? null : parseDate(c.lastReviewed!);
  return FsrsCard(
    stability: c.stability,
    difficulty: c.difficulty,
    state: c.state,
    lapses: c.lapses,
    reps: c.reps,
    elapsedDays: c.elapsedDays,
    scheduledDays: c.scheduledDays,
    lastReview: last,
  );
}

class SrsRepo {
  Future<Database> get _db => DbHelper.instance.db;

  final Fsrs _fsrs = const Fsrs(requestRetention: 0.9);

  /// Adds the day's words to SRS if they're not already there.
  /// Called after the user completes the Vocabulary task for a day.
  Future<void> seedWordsFromDay(int dayId) async {
    final db = await _db;
    final words = await db.query(
      'words',
      columns: ['id'],
      where: 'day_id = ?',
      whereArgs: [dayId],
    );
    final t = fmtDate(today());
    await db.transaction((txn) async {
      final b = txn.batch();
      for (final w in words) {
        b.insert(
          'srs',
          {
            'word_id': w['id'],
            'next_review_date': t,
            'last_reviewed': null,
            'stability': 0,
            'difficulty': 0,
            'state': 0,
            'lapses': 0,
            'reps': 0,
            'elapsed_days': 0,
            'scheduled_days': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await b.commit(noResult: true);
    });
  }

  /// Cards due today (or earlier), with their word data joined.
  /// Sort puts new cards (state=0) after review cards so the user
  /// warms up on words they've seen before.
  Future<List<({SrsCard card, Word word})>> dueToday() async {
    final db = await _db;
    final t = fmtDate(today());
    final rows = await db.rawQuery(
      '''
      SELECT s.*, w.id AS id, w.day_id, w.word_en, w.ipa, w.meaning_ar,
             w.example_en, w.example_ar, w.audio_ref
      FROM srs s
      INNER JOIN words w ON w.id = s.word_id
      WHERE s.next_review_date <= ?
      ORDER BY (s.state = 0) ASC, s.next_review_date ASC, s.word_id ASC
      ''',
      [t],
    );
    return rows.map((r) {
      final card = SrsCard.fromMap(r);
      final word = Word.fromMap(r);
      return (card: card, word: word);
    }).toList();
  }

  /// Words grouped by the day they came from, due today.
  Future<Map<int, int>> dueCountByDay() async {
    final db = await _db;
    final t = fmtDate(today());
    final rows = await db.rawQuery(
      '''
      SELECT w.day_id AS day_id, COUNT(*) AS c
      FROM srs s
      INNER JOIN words w ON w.id = s.word_id
      WHERE s.next_review_date <= ?
      GROUP BY w.day_id
      ORDER BY w.day_id ASC
      ''',
      [t],
    );
    return {for (final r in rows) r['day_id'] as int: r['c'] as int};
  }

  /// What interval (in days) would each grade produce for the given card?
  /// Used by the Review UI to show "Again 1d · Hard 3d · Good 14d" etc.
  Map<SrsGrade, int> previewIntervals(SrsCard card) {
    final fc = _toFsrs(card);
    final now = today();
    final raw = _fsrs.previewIntervals(fc, now);
    return {
      SrsGrade.again: raw[FsrsRating.again]!,
      SrsGrade.hard: raw[FsrsRating.hard]!,
      SrsGrade.good: raw[FsrsRating.good]!,
      SrsGrade.easy: raw[FsrsRating.easy]!,
    };
  }

  /// Apply a grade and persist.
  Future<SrsCard> grade(SrsCard card, SrsGrade grade) async {
    final db = await _db;
    final now = today();
    final info = _fsrs.schedule(
      card: _toFsrs(card),
      rating: _gradeToRating(grade),
      now: now,
    );
    final updated = info.card;
    final nextDate = fmtDate(info.due);
    final lastDate = fmtDate(now);

    await db.update(
      'srs',
      {
        'stability': updated.stability,
        'difficulty': updated.difficulty,
        'state': updated.state,
        'lapses': updated.lapses,
        'reps': updated.reps,
        'elapsed_days': updated.elapsedDays,
        'scheduled_days': updated.scheduledDays,
        'next_review_date': nextDate,
        'last_reviewed': lastDate,
      },
      where: 'word_id = ?',
      whereArgs: [card.wordId],
    );

    return SrsCard(
      wordId: card.wordId,
      nextReviewDate: nextDate,
      lastReviewed: lastDate,
      stability: updated.stability,
      difficulty: updated.difficulty,
      state: updated.state,
      lapses: updated.lapses,
      reps: updated.reps,
      elapsedDays: updated.elapsedDays,
      scheduledDays: updated.scheduledDays,
    );
  }

  Future<int> totalSeenWords() async {
    final db = await _db;
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM srs');
    return (r.first['c'] as int?) ?? 0;
  }

  /// How many cards the user already reviewed today (last_reviewed = today).
  /// Lets the empty-state UI distinguish "finished for the day" from
  /// "haven't started yet".
  Future<int> reviewedTodayCount() async {
    final db = await _db;
    final t = fmtDate(today());
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM srs WHERE last_reviewed = ?',
      [t],
    );
    return (r.first['c'] as int?) ?? 0;
  }

  /// Aggregate stats for the Achraf review screen header / Progress page.
  Future<({int total, int learning, int review, int relearning, int leeches})>
      memoryStats() async {
    final db = await _db;
    final r = await db.rawQuery('''
      SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN state = 1 THEN 1 ELSE 0 END) AS learning,
        SUM(CASE WHEN state = 2 THEN 1 ELSE 0 END) AS review,
        SUM(CASE WHEN state = 3 THEN 1 ELSE 0 END) AS relearning,
        SUM(CASE WHEN lapses >= 4 THEN 1 ELSE 0 END) AS leeches
      FROM srs
    ''');
    final row = r.first;
    return (
      total: (row['total'] as int?) ?? 0,
      learning: (row['learning'] as int?) ?? 0,
      review: (row['review'] as int?) ?? 0,
      relearning: (row['relearning'] as int?) ?? 0,
      leeches: (row['leeches'] as int?) ?? 0,
    );
  }
}
