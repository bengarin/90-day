import 'package:sqflite/sqflite.dart';

import '../../core/date_utils.dart';
import '../database/db_helper.dart';
import '../models/models.dart';

class StatsRepo {
  Future<Database> get _db => DbHelper.instance.db;

  Future<UserStats> get() async {
    final db = await _db;
    final rows = await db.query('user_stats', where: 'id = 1');
    return UserStats.fromMap(rows.first);
  }

  Future<void> update({
    String? name,
    String? dailyGoal,
    int? currentStreak,
    int? longestStreak,
    String? lastActiveDate,
    int? totalMinutes,
    int? totalWords,
    String? currentLevel,
    String? language,
  }) async {
    final db = await _db;
    final patch = <String, Object?>{};
    if (name != null) patch['name'] = name;
    if (dailyGoal != null) patch['daily_goal'] = dailyGoal;
    if (currentStreak != null) patch['current_streak'] = currentStreak;
    if (longestStreak != null) patch['longest_streak'] = longestStreak;
    if (lastActiveDate != null) patch['last_active_date'] = lastActiveDate;
    if (totalMinutes != null) patch['total_minutes'] = totalMinutes;
    if (totalWords != null) patch['total_words'] = totalWords;
    if (currentLevel != null) patch['current_level'] = currentLevel;
    if (language != null) patch['language'] = language;
    if (patch.isEmpty) return;
    await db.update('user_stats', patch, where: 'id = 1');
  }

  /// Bump the streak after a day is completed. If the user already completed
  /// a day today, no-op. Otherwise:
  ///  - same day or +1 from last_active_date: streak += 1
  ///  - gap > 1 day: streak resets to 1
  Future<UserStats> bumpStreakOnDayComplete(int minutesAdded, int wordsAdded) async {
    final db = await _db;
    final cur = await get();
    final t = fmtDate(today());

    int newStreak = cur.currentStreak;
    if (cur.lastActiveDate == null) {
      newStreak = 1;
    } else if (cur.lastActiveDate == t) {
      newStreak = cur.currentStreak == 0 ? 1 : cur.currentStreak;
    } else {
      final last = parseDate(cur.lastActiveDate!);
      final gap = daysBetween(last, today());
      if (gap == 1) {
        newStreak = cur.currentStreak + 1;
      } else if (gap > 1) {
        newStreak = 1;
      } else {
        // gap == 0 (same day): keep
        newStreak = cur.currentStreak == 0 ? 1 : cur.currentStreak;
      }
    }
    final newLongest =
        newStreak > cur.longestStreak ? newStreak : cur.longestStreak;

    final updatedMinutes = cur.totalMinutes + minutesAdded;
    final updatedWords = cur.totalWords + wordsAdded;

    // Keep the user's chosen starting level unless they've passed a
    // milestone that pushes them up. Never downgrade.
    final autoLevel = _levelFor(updatedWords);
    final level = _maxLevel(cur.currentLevel, autoLevel);

    await db.update(
      'user_stats',
      {
        'current_streak': newStreak,
        'longest_streak': newLongest,
        'last_active_date': t,
        'total_minutes': updatedMinutes,
        'total_words': updatedWords,
        'current_level': level,
      },
      where: 'id = 1',
    );

    return cur.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastActiveDate: t,
      totalMinutes: updatedMinutes,
      totalWords: updatedWords,
      currentLevel: level,
    );
  }

  static const _levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  String _maxLevel(String a, String b) {
    final ia = _levelOrder.indexOf(a);
    final ib = _levelOrder.indexOf(b);
    return ia >= ib ? a : b;
  }

  /// Simple word-count -> CEFR level mapping (upgrade hint only).
  String _levelFor(int words) {
    if (words >= 1500) return 'B2';
    if (words >= 800) return 'B1';
    if (words >= 300) return 'A2';
    return 'A1';
  }

  /// How many of the 90 days are completed (uses day_state).
  Future<int> completedDayCount() async {
    final db = await _db;
    final r = await db.rawQuery(
      "SELECT COUNT(*) AS c FROM day_state WHERE status = 'completed'",
    );
    return (r.first['c'] as int?) ?? 0;
  }

  /// Setting helpers (key/value store).
  Future<String?> getSetting(String key) async {
    final db = await _db;
    final r = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (r.isEmpty) return null;
    return r.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await _db;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Reset user state — keeps content, wipes progress.
  Future<void> resetAll() async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update('user_stats', {
        'name': '',
        'daily_goal': '',
        'current_streak': 0,
        'longest_streak': 0,
        'last_active_date': null,
        'total_minutes': 0,
        'total_words': 0,
        'current_level': 'A1',
      }, where: 'id = 1');
      await txn.update('day_state', {
        'status': 'available',
        'completed_at': null,
        'minutes_spent': 0,
      });
      await txn.update('task_state', {
        'is_done': 0,
        'done_at': null,
      });
      await txn.delete('srs');
      await txn.delete('settings');
    });
  }
}
