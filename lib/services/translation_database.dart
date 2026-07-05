import 'dart:convert';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/translation_record.dart';

class TranslationDatabase {
  static const _dbName = 'lango.db';
  static const _tableName = 'translations';
  static const _historyKey = 'translation_history';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            source_text TEXT NOT NULL,
            translated_text TEXT NOT NULL,
            source_lang TEXT NOT NULL,
            target_lang TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            is_offline INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );

    await _migrateFromSharedPreferences(db);
    return db;
  }

  Future<void> _migrateFromSharedPreferences(Database db) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return;

    final existing = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );
    if (existing != null && existing > 0) {
      await prefs.remove(_historyKey);
      return;
    }

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final batch = db.batch();
      for (final item in list) {
        final record = TranslationRecord.fromJson(item as Map<String, dynamic>);
        batch.insert(_tableName, _toRow(record));
      }
      await batch.commit(noResult: true);
      await prefs.remove(_historyKey);
    } catch (_) {}
  }

  Map<String, Object?> _toRow(TranslationRecord record) => {
        'id': record.id,
        'source_text': record.sourceText,
        'translated_text': record.translatedText,
        'source_lang': record.sourceLang,
        'target_lang': record.targetLang,
        'timestamp': record.timestamp.toIso8601String(),
        'is_favorite': record.isFavorite ? 1 : 0,
        'is_offline': record.isOffline ? 1 : 0,
      };

  TranslationRecord _fromRow(Map<String, Object?> row) {
    return TranslationRecord(
      id: row['id'] as String,
      sourceText: row['source_text'] as String,
      translatedText: row['translated_text'] as String,
      sourceLang: row['source_lang'] as String,
      targetLang: row['target_lang'] as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      isFavorite: (row['is_favorite'] as int) == 1,
      isOffline: (row['is_offline'] as int) == 1,
    );
  }

  Future<void> insert(TranslationRecord record) async {
    final db = await database;
    await db.insert(
      _tableName,
      _toRow(record),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TranslationRecord>> getAll() async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      orderBy: 'timestamp DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<List<TranslationRecord>> getFavorites() async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'timestamp DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE $_tableName
      SET is_favorite = CASE WHEN is_favorite = 1 THEN 0 ELSE 1 END
      WHERE id = ?
      ''',
      [id],
    );
  }

  Future<void> deleteById(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
