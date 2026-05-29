import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens (and seeds, on first run) the local SQLite database.
/// Content tables and state tables are kept separate so content can be
/// re-seeded later without touching the user's progress.
class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'english_coach_90.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createSchema(db);
        await _seedContentFromAssets(db);
        await _seedInitialState(db);
      },
    );
  }

  // ---------------------------------------------------------------
  // Schema
  // ---------------------------------------------------------------
  Future<void> _createSchema(Database db) async {
    final batch = db.batch();

    // Content tables.
    batch.execute('''
      CREATE TABLE phases(
        id INTEGER PRIMARY KEY,
        name_ar TEXT NOT NULL,
        day_start INTEGER NOT NULL,
        day_end INTEGER NOT NULL,
        description TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE days(
        id INTEGER PRIMARY KEY,
        phase_id INTEGER NOT NULL,
        week_no INTEGER NOT NULL,
        title_ar TEXT NOT NULL,
        topic_en TEXT NOT NULL,
        topic_ar TEXT NOT NULL,
        est_minutes INTEGER NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE words(
        id INTEGER PRIMARY KEY,
        day_id INTEGER NOT NULL,
        word_en TEXT NOT NULL,
        ipa TEXT,
        meaning_ar TEXT NOT NULL,
        example_en TEXT,
        example_ar TEXT,
        audio_ref TEXT
      )
    ''');
    batch.execute('CREATE INDEX idx_words_day ON words(day_id)');

    batch.execute('''
      CREATE TABLE sentences(
        id INTEGER PRIMARY KEY,
        day_id INTEGER NOT NULL,
        sentence_en TEXT NOT NULL,
        translation_ar TEXT NOT NULL,
        audio_ref TEXT
      )
    ''');
    batch.execute('CREATE INDEX idx_sentences_day ON sentences(day_id)');

    batch.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY,
        day_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        label_ar TEXT NOT NULL,
        instructions_ar TEXT NOT NULL,
        duration_min INTEGER NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_tasks_day ON tasks(day_id)');

    // State tables.
    batch.execute('''
      CREATE TABLE user_stats(
        id INTEGER PRIMARY KEY,
        name TEXT,
        daily_goal TEXT,
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        last_active_date TEXT,
        total_minutes INTEGER NOT NULL DEFAULT 0,
        total_words INTEGER NOT NULL DEFAULT 0,
        current_level TEXT NOT NULL DEFAULT 'A1'
      )
    ''');

    batch.execute('''
      CREATE TABLE day_state(
        day_id INTEGER PRIMARY KEY,
        status TEXT NOT NULL,
        completed_at TEXT,
        minutes_spent INTEGER NOT NULL DEFAULT 0
      )
    ''');

    batch.execute('''
      CREATE TABLE task_state(
        task_id INTEGER PRIMARY KEY,
        day_id INTEGER NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0,
        done_at TEXT
      )
    ''');
    batch.execute('CREATE INDEX idx_task_state_day ON task_state(day_id)');

    batch.execute('''
      CREATE TABLE srs(
        word_id INTEGER PRIMARY KEY,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        interval_days INTEGER NOT NULL DEFAULT 1,
        repetitions INTEGER NOT NULL DEFAULT 0,
        next_review_date TEXT NOT NULL,
        last_reviewed TEXT
      )
    ''');
    batch.execute('CREATE INDEX idx_srs_next ON srs(next_review_date)');

    batch.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------
  // Seed content from bundled JSON
  // ---------------------------------------------------------------
  Future<void> _seedContentFromAssets(Database db) async {
    Future<List<dynamic>> load(String name) async {
      final raw = await rootBundle.loadString('assets/data/$name');
      return jsonDecode(raw) as List<dynamic>;
    }

    final phases = await load('phases.json');
    final days = await load('days.json');
    final words = await load('words.json');
    final sentences = await load('sentences.json');
    final tasks = await load('tasks.json');

    await db.transaction((txn) async {
      final b = txn.batch();
      for (final r in phases) {
        b.insert('phases', Map<String, Object?>.from(r as Map));
      }
      for (final r in days) {
        b.insert('days', Map<String, Object?>.from(r as Map));
      }
      for (final r in words) {
        b.insert('words', Map<String, Object?>.from(r as Map));
      }
      for (final r in sentences) {
        b.insert('sentences', Map<String, Object?>.from(r as Map));
      }
      for (final r in tasks) {
        b.insert('tasks', Map<String, Object?>.from(r as Map));
      }
      await b.commit(noResult: true);
    });
  }

  // ---------------------------------------------------------------
  // Seed initial state (day_state, task_state, user_stats)
  // ---------------------------------------------------------------
  Future<void> _seedInitialState(Database db) async {
    await db.insert('user_stats', {
      'id': 1,
      'name': '',
      'daily_goal': '',
      'current_streak': 0,
      'longest_streak': 0,
      'last_active_date': null,
      'total_minutes': 0,
      'total_words': 0,
      'current_level': 'A1',
    });

    final days =
        await db.query('days', columns: ['id'], orderBy: 'id ASC');
    final tasks = await db.query('tasks', columns: ['id', 'day_id']);

    await db.transaction((txn) async {
      final b = txn.batch();
      for (final d in days) {
        final id = d['id'] as int;
        b.insert('day_state', {
          'day_id': id,
          // Day 1 is available immediately; rest are available too because
          // the user can move freely. We mark progression with task completion.
          'status': 'available',
          'completed_at': null,
          'minutes_spent': 0,
        });
      }
      for (final t in tasks) {
        b.insert('task_state', {
          'task_id': t['id'],
          'day_id': t['day_id'],
          'is_done': 0,
          'done_at': null,
        });
      }
      await b.commit(noResult: true);
    });
  }
}
