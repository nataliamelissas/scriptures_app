import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Manages the SQLite database for study projects and notes.
class AppDatabase {
  static const _dbName = 'scriptures_app.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        last_opened_at TEXT NOT NULL,
        last_volume TEXT,
        last_book_api_id TEXT,
        last_chapter INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        volume TEXT NOT NULL,
        book_api_id TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse_number INTEGER NOT NULL,
        type TEXT NOT NULL,
        content TEXT,
        highlight_color INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    // Index for fast lookup: "get all notes for this chapter in this project"
    await db.execute('''
      CREATE INDEX idx_notes_lookup
      ON notes(project_id, volume, book_api_id, chapter)
    ''');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
