import 'package:sqflite/sqflite.dart';

import '../database/db_helper.dart';
import '../models/models.dart';

/// Reads day metadata and per-day state. Also marks the day as completed
/// when all of its tasks are done.
class DayRepo {
  Future<Database> get _db => DbHelper.instance.db;

  Future<List<Day>> allDays() async {
    final db = await _db;
    final rows = await db.query('days', orderBy: 'id ASC');
    return rows.map((r) => Day.fromMap(r)).toList();
  }

  Future<Day> getDay(int id) async {
    final db = await _db;
    final rows = await db.query('days', where: 'id = ?', whereArgs: [id]);
    return Day.fromMap(rows.first);
  }

  Future<List<Phase>> allPhases() async {
    final db = await _db;
    final rows = await db.query('phases', orderBy: 'id ASC');
    return rows.map((r) => Phase.fromMap(r)).toList();
  }

  Future<DayState> getDayState(int dayId) async {
    final db = await _db;
    final rows =
        await db.query('day_state', where: 'day_id = ?', whereArgs: [dayId]);
    return DayState.fromMap(rows.first);
  }

  Future<Map<int, DayState>> allDayStates() async {
    final db = await _db;
    final rows = await db.query('day_state');
    return {for (final r in rows) r['day_id'] as int: DayState.fromMap(r)};
  }

  Future<void> setDayCompleted(int dayId, {String? at}) async {
    final db = await _db;
    await db.update(
      'day_state',
      {
        'status': 'completed',
        'completed_at': at ?? DateTime.now().toIso8601String(),
      },
      where: 'day_id = ?',
      whereArgs: [dayId],
    );
  }

  /// Adds minutes spent on a day; used after completing a task.
  Future<void> addMinutes(int dayId, int minutes) async {
    final db = await _db;
    await db.rawUpdate(
      'UPDATE day_state SET minutes_spent = minutes_spent + ? WHERE day_id = ?',
      [minutes, dayId],
    );
  }
}
