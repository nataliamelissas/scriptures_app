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
      ..orderBy([(p) => OrderingTerm.desc(p.lastOpenedAt)]);
    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<StudyProject> create(String name, {String? description}) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _db.into(_db.projects).insert(ProjectsCompanion.insert(
          id: id,
          name: name,
          description: Value(description),
          createdAt: now,
          lastOpenedAt: now,
        ));

    return StudyProject(
      id: id,
      name: name,
      description: description,
      createdAt: now,
      lastOpenedAt: now,
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
      lastVolume: Value(project.lastPosition?.volume.apiVolumeId),
      lastBookApiId: Value(project.lastPosition?.bookApiId),
      lastChapter: Value(project.lastPosition?.chapter),
      lastVerse: Value(project.lastPosition?.verseNumber),
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
