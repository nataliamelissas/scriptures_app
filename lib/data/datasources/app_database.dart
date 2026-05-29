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

  // Legacy single-volume column from schema v1/v2. No longer read; kept
  // nullable so the v3 migration can leave the column intact (SQLite
  // does not support DROP COLUMN reliably on older Android versions).
  TextColumn get defaultVolumeId => text().nullable()();

  // Legacy single-position columns from schema v1/v2. Migrated into the
  // ProjectPositions table at v3; no longer written or read.
  TextColumn get lastVolume => text().nullable()();
  TextColumn get lastBookApiId => text().nullable()();
  TextColumn get lastBookTitle => text().nullable()();
  IntColumn get lastChapter => integer().nullable()();
  IntColumn get lastVerse => integer().nullable()();

  // ── v3 ──
  // Comma-separated user-defined tags.
  TextColumn get tags => text().nullable()();
  // Comma-separated standard work api ids added to this project.
  TextColumn get volumes => text().nullable()();
  // Last-touched standard work api id — drives where the project resumes.
  TextColumn get activeVolumeId => text().nullable()();

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

/// Per-volume reading positions. A project may have one row per
/// standard work it has been read from.
class ProjectPositions extends Table {
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get volume => text()();
  TextColumn get bookApiId => text()();
  TextColumn get bookTitle => text()();
  IntColumn get chapter => integer()();
  IntColumn get verseNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {projectId, volume};
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

@DriftDatabase(tables: [Projects, Notes, ProjectPositions, CachedChapters])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(projects, projects.archivedAt);
            await m.addColumn(projects, projects.defaultVolumeId);
            await m.addColumn(projects, projects.lastBookTitle);
          }
          if (from < 3) {
            await m.addColumn(projects, projects.tags);
            await m.addColumn(projects, projects.volumes);
            await m.addColumn(projects, projects.activeVolumeId);
            await m.createTable(projectPositions);

            // Promote each legacy reading position into the new table.
            await customStatement(
              'INSERT OR IGNORE INTO project_positions '
              '(project_id, volume, book_api_id, book_title, chapter, verse_number) '
              'SELECT id, last_volume, last_book_api_id, '
              'COALESCE(last_book_title, last_book_api_id), last_chapter, last_verse '
              'FROM projects '
              'WHERE last_volume IS NOT NULL '
              'AND last_book_api_id IS NOT NULL '
              'AND last_chapter IS NOT NULL',
            );

            // Seed volumes from defaultVolumeId, unioned with the last-read
            // volume in case the user had been reading something different.
            await customStatement(
              "UPDATE projects SET volumes = "
              "CASE "
              "  WHEN default_volume_id IS NOT NULL AND last_volume IS NOT NULL "
              "    AND default_volume_id <> last_volume "
              "    THEN default_volume_id || ',' || last_volume "
              "  WHEN default_volume_id IS NOT NULL THEN default_volume_id "
              "  WHEN last_volume IS NOT NULL THEN last_volume "
              "  ELSE NULL "
              "END",
            );

            await customStatement(
              'UPDATE projects SET active_volume_id = '
              'COALESCE(last_volume, default_volume_id)',
            );
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
