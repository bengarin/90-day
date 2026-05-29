import 'package:sqflite/sqflite.dart';

import '../database/db_helper.dart';
import '../models/models.dart';

class VocabRepo {
  Future<Database> get _db => DbHelper.instance.db;

  Future<List<Word>> wordsForDay(int dayId) async {
    final db = await _db;
    final rows = await db.query(
      'words',
      where: 'day_id = ?',
      whereArgs: [dayId],
      orderBy: 'id ASC',
    );
    return rows.map((r) => Word.fromMap(r)).toList();
  }

  Future<List<Sentence>> sentencesForDay(int dayId) async {
    final db = await _db;
    final rows = await db.query(
      'sentences',
      where: 'day_id = ?',
      whereArgs: [dayId],
      orderBy: 'id ASC',
    );
    return rows.map((r) => Sentence.fromMap(r)).toList();
  }

  Future<List<Task>> tasksForDay(int dayId) async {
    final db = await _db;
    final rows = await db.query(
      'tasks',
      where: 'day_id = ?',
      whereArgs: [dayId],
      orderBy: 'sort_order ASC',
    );
    return rows.map((r) => Task.fromMap(r)).toList();
  }

  Future<Map<int, TaskState>> taskStatesForDay(int dayId) async {
    final db = await _db;
    final rows = await db
        .query('task_state', where: 'day_id = ?', whereArgs: [dayId]);
    return {for (final r in rows) r['task_id'] as int: TaskState.fromMap(r)};
  }

  Future<void> setTaskDone(int taskId, bool done) async {
    final db = await _db;
    await db.update(
      'task_state',
      {
        'is_done': done ? 1 : 0,
        'done_at': done ? DateTime.now().toIso8601String() : null,
      },
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  Future<Word> getWord(int wordId) async {
    final db = await _db;
    final rows =
        await db.query('words', where: 'id = ?', whereArgs: [wordId]);
    return Word.fromMap(rows.first);
  }
}
