import 'package:flutter/foundation.dart' show kIsWeb;
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
  DateTimeColumn get archivedAt => dateTime().nullable()();

  // Volume picked during project creation — used to navigate when there's no
  // reading position yet, and as the project's "home" standard work.
  TextColumn get defaultVolumeId => text().nullable()();

  // Reading position (nullable — null means "not started yet")
  TextColumn get lastVolume => text().nullable()();
  TextColumn get lastBookApiId => text().nullable()();
  TextColumn get lastBookTitle => text().nullable()();
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(projects, projects.archivedAt);
            await m.addColumn(projects, projects.defaultVolumeId);
            await m.addColumn(projects, projects.lastBookTitle);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: DbConfig.fileName,
      web: kIsWeb
          ? DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            )
          : null,
    );
  }
}
