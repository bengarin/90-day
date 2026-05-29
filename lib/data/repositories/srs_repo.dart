import 'package:sqflite/sqflite.dart';

import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../database/db_helper.dart';
import '../models/models.dart';

/// Grade values used by the Review screen buttons.
enum SrsGrade { hard, good, easy }

class SrsRepo {
  Future<Database> get _db => DbHelper.instance.db;

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
            'ease_factor': 2.5,
            'interval_days': 1,
            'repetitions': 0,
            // First review = tomorrow.
            'next_review_date': fmtDate(today().add(const Duration(days: 1))),
            'last_reviewed': null,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      // Force at least one card to be due today so the Review screen
      // doesn't feel empty on day 1.
      if (words.isNotEmpty) {
        b.update(
          'srs',
          {'next_review_date': t},
          where: 'word_id = ?',
          whereArgs: [words.first['id']],
        );
      }
      await b.commit(noResult: true);
    });
  }

  /// Cards due today (or earlier), with their word data joined.
  Future<List<({SrsCard card, Word word})>> dueToday() async {
    final db = await _db;
    final t = fmtDate(today());
    final rows = await db.rawQuery(
      '''
      SELECT s.*, w.day_id, w.word_en, w.ipa, w.meaning_ar,
             w.example_en, w.example_ar, w.audio_ref
      FROM srs s
      INNER JOIN words w ON w.id = s.word_id
      WHERE s.next_review_date <= ?
      ORDER BY s.next_review_date ASC, s.word_id ASC
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

  /// Apply the SM-2 simplified update.
  /// hard => reset interval to 1, lower ease.
  /// good => next step in the interval ladder.
  /// easy => skip a step + raise ease.
  Future<SrsCard> grade(SrsCard card, SrsGrade grade) async {
    final db = await _db;
    int newRep = card.repetitions;
    double newEase = card.easeFactor;
    int newInterval = card.intervalDays;

    final ladder = AppConstants.srsIntervals;

    if (grade == SrsGrade.hard) {
      newRep = 0;
      newInterval = ladder.first; // 1 day
      newEase = (card.easeFactor - 0.2).clamp(1.3, 2.8);
    } else if (grade == SrsGrade.good) {
      newRep = card.repetitions + 1;
      final idx = newRep.clamp(0, ladder.length - 1);
      newInterval = ladder[idx];
      newEase = (card.easeFactor + 0.0).clamp(1.3, 2.8);
    } else {
      // easy
      newRep = card.repetitions + 2;
      final idx = newRep.clamp(0, ladder.length - 1);
      newInterval = ladder[idx];
      newEase = (card.easeFactor + 0.15).clamp(1.3, 2.8);
    }

    final next = fmtDate(today().add(Duration(days: newInterval)));
    final last = fmtDate(today());

    await db.update(
      'srs',
      {
        'ease_factor': newEase,
        'interval_days': newInterval,
        'repetitions': newRep,
        'next_review_date': next,
        'last_reviewed': last,
      },
      where: 'word_id = ?',
      whereArgs: [card.wordId],
    );

    return SrsCard(
      wordId: card.wordId,
      easeFactor: newEase,
      intervalDays: newInterval,
      repetitions: newRep,
      nextReviewDate: next,
      lastReviewed: last,
    );
  }

  Future<int> totalSeenWords() async {
    final db = await _db;
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM srs');
    return (r.first['c'] as int?) ?? 0;
  }
}
