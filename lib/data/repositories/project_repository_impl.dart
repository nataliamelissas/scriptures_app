import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/app_database.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ProjectRepositoryImpl({required AppDatabase db}) : _db = db;

  @override
  Future<List<StudyProject>> getAll() async {
    final query = _db.select(_db.projects)
      ..where((p) => p.archivedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.lastOpenedAt)]);
    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<StudyProject>> getArchived() async {
    final query = _db.select(_db.projects)
      ..where((p) => p.archivedAt.isNotNull())
      ..orderBy([(p) => OrderingTerm.desc(p.archivedAt)]);
    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<StudyProject> create(
    String name, {
    String? description,
    StandardWork? defaultVolume,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _db.into(_db.projects).insert(ProjectsCompanion.insert(
          id: id,
          name: name,
          description: Value(description),
          createdAt: now,
          lastOpenedAt: now,
          defaultVolumeId: Value(defaultVolume?.apiVolumeId),
        ));

    return StudyProject(
      id: id,
      name: name,
      description: description,
      createdAt: now,
      lastOpenedAt: now,
      defaultVolume: defaultVolume,
    );
  }

  @override
  Future<void> update(StudyProject project) async {
    await (_db.update(_db.projects)
          ..where((p) => p.id.equals(project.id)))
        .write(ProjectsCompanion(
      name: Value(project.name),
      description: Value(project.description),
      lastOpenedAt: Value(project.lastOpenedAt),
      archivedAt: Value(project.archivedAt),
      defaultVolumeId: Value(project.defaultVolume?.apiVolumeId),
      lastVolume: Value(project.lastPosition?.volume.apiVolumeId),
      lastBookApiId: Value(project.lastPosition?.bookApiId),
      lastBookTitle: Value(project.lastPosition?.bookTitle),
      lastChapter: Value(project.lastPosition?.chapter),
      lastVerse: Value(project.lastPosition?.verseNumber),
    ));
  }

  @override
  Future<void> setArchived(String projectId, bool archived) async {
    await (_db.update(_db.projects)..where((p) => p.id.equals(projectId)))
        .write(ProjectsCompanion(
      archivedAt: Value(archived ? DateTime.now() : null),
    ));
  }

  @override
  Future<void> delete(String projectId) async {
    // Delete notes first (Drift doesn't auto-cascade by default at runtime)
    await (_db.delete(_db.notes)
          ..where((n) => n.projectId.equals(projectId)))
        .go();
    await (_db.delete(_db.projects)..where((p) => p.id.equals(projectId)))
        .go();
  }

  // ── Mapping ───────────────────────────────────────────────────────────

  static StudyProject _toEntity(Project row) {
    ReadingPosition? pos;
    if (row.lastVolume != null &&
        row.lastBookApiId != null &&
        row.lastChapter != null) {
      pos = ReadingPosition(
        volume: _volumeFromApiId(row.lastVolume!),
        bookApiId: row.lastBookApiId!,
        bookTitle: row.lastBookTitle ?? row.lastBookApiId!,
        chapter: row.lastChapter!,
        verseNumber: row.lastVerse,
      );
    }

    return StudyProject(
      id: row.id,
      name: row.name,
      description: row.description,
      createdAt: row.createdAt,
      lastOpenedAt: row.lastOpenedAt,
      archivedAt: row.archivedAt,
      defaultVolume:
          row.defaultVolumeId != null ? _volumeFromApiId(row.defaultVolumeId!) : null,
      lastPosition: pos,
    );
  }

  static StandardWork _volumeFromApiId(String id) => switch (id) {
        'oldtestament' => StandardWork.oldTestament,
        'newtestament' => StandardWork.newTestament,
        'bookofmormon' => StandardWork.bookOfMormon,
        'doctrineandcovenants' => StandardWork.doctrineAndCovenants,
        'pearlofgreatprice' => StandardWork.pearlOfGreatPrice,
        _ => StandardWork.bookOfMormon,
      };
}
