import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../core/constants.dart';

part 'app_database.g.dart';

/// Study projects table — each row is a named study session.
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime()();

  // Reading position (nullable — null means "not started yet")
  TextColumn get lastVolume => text().nullable()();
  TextColumn get lastBookApiId => text().nullable()();
  IntColumn get lastChapter => integer().nullable()();
  IntColumn get lastVerse => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Notes table — highlights, notes, bookmarks scoped to a project + verse.
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get volume => text()();
  TextColumn get bookApiId => text()();
  IntColumn get chapter => integer()();
  IntColumn get verseNumber => integer()();
  TextColumn get type => text()(); // NoteType.name: 'highlight', 'note', 'bookmark'
  TextColumn get content => text().nullable()();
  IntColumn get highlightColor => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached chapter content — downloaded from API, stored locally for offline use.
class CachedChapters extends Table {
  TextColumn get volume => text()();
  TextColumn get bookApiId => text()();
  IntColumn get chapterNumber => integer()();
  TextColumn get jsonContent => text()(); // Full API response as JSON
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {volume, bookApiId, chapterNumber};
}

@DriftDatabase(tables: [Projects, Notes, CachedChapters])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: DbConfig.fileName);
  }
}
