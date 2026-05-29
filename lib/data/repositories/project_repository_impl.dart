import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/app_database.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();
  static const _listSeparator = ',';

  ProjectRepositoryImpl({required AppDatabase db}) : _db = db;

  @override
  Future<List<StudyProject>> getAll() async {
    final query = _db.select(_db.projects)
      ..where((p) => p.archivedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.lastOpenedAt)]);
    final rows = await query.get();
    return _hydrate(rows);
  }

  @override
  Future<List<StudyProject>> getArchived() async {
    final query = _db.select(_db.projects)
      ..where((p) => p.archivedAt.isNotNull())
      ..orderBy([(p) => OrderingTerm.desc(p.archivedAt)]);
    final rows = await query.get();
    return _hydrate(rows);
  }

  @override
  Future<StudyProject> create(
    String name, {
    String? description,
    List<String> tags = const [],
    List<StandardWork> volumes = const [],
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _db.into(_db.projects).insert(ProjectsCompanion.insert(
          id: id,
          name: name,
          description: Value(description),
          createdAt: now,
          lastOpenedAt: now,
          tags: Value(_encodeStringList(tags)),
          volumes: Value(_encodeVolumes(volumes)),
        ));

    return StudyProject(
      id: id,
      name: name,
      description: description,
      createdAt: now,
      lastOpenedAt: now,
      tags: List.unmodifiable(tags),
      volumes: List.unmodifiable(volumes),
    );
  }

  @override
  Future<void> update(StudyProject project) async {
    await _db.transaction(() async {
      await (_db.update(_db.projects)
            ..where((p) => p.id.equals(project.id)))
          .write(ProjectsCompanion(
        name: Value(project.name),
        description: Value(project.description),
        lastOpenedAt: Value(project.lastOpenedAt),
        archivedAt: Value(project.archivedAt),
        tags: Value(_encodeStringList(project.tags)),
        volumes: Value(_encodeVolumes(project.volumes)),
        activeVolumeId: Value(project.activeVolume?.apiVolumeId),
      ));

      // Replace positions wholesale: only the volumes currently in the
      // entity's positions map should persist.
      await (_db.delete(_db.projectPositions)
            ..where((pp) => pp.projectId.equals(project.id)))
          .go();
      for (final entry in project.positions.entries) {
        final pos = entry.value;
        await _db.into(_db.projectPositions).insert(
              ProjectPositionsCompanion.insert(
                projectId: project.id,
                volume: entry.key.apiVolumeId,
                bookApiId: pos.bookApiId,
                bookTitle: pos.bookTitle,
                chapter: pos.chapter,
                verseNumber: Value(pos.verseNumber),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
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
    await _db.transaction(() async {
      await (_db.delete(_db.notes)
            ..where((n) => n.projectId.equals(projectId)))
          .go();
      await (_db.delete(_db.projectPositions)
            ..where((pp) => pp.projectId.equals(projectId)))
          .go();
      await (_db.delete(_db.projects)..where((p) => p.id.equals(projectId)))
          .go();
    });
  }

  // ── Hydration ─────────────────────────────────────────────────────────

  Future<List<StudyProject>> _hydrate(List<Project> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();
    final positionRows = await (_db.select(_db.projectPositions)
          ..where((pp) => pp.projectId.isIn(ids)))
        .get();

    final positionsByProject = <String, Map<StandardWork, ReadingPosition>>{};
    for (final pp in positionRows) {
      final vol = _volumeFromApiId(pp.volume);
      positionsByProject
          .putIfAbsent(pp.projectId, () => {})[vol] = ReadingPosition(
        volume: vol,
        bookApiId: pp.bookApiId,
        bookTitle: pp.bookTitle,
        chapter: pp.chapter,
        verseNumber: pp.verseNumber,
      );
    }

    return rows
        .map((r) => _toEntity(r, positionsByProject[r.id] ?? const {}))
        .toList();
  }

  static StudyProject _toEntity(
    Project row,
    Map<StandardWork, ReadingPosition> positions,
  ) {
    return StudyProject(
      id: row.id,
      name: row.name,
      description: row.description,
      createdAt: row.createdAt,
      lastOpenedAt: row.lastOpenedAt,
      archivedAt: row.archivedAt,
      tags: List.unmodifiable(_decodeStringList(row.tags)),
      volumes: List.unmodifiable(_decodeVolumes(row.volumes)),
      activeVolume: row.activeVolumeId != null
          ? _volumeFromApiId(row.activeVolumeId!)
          : null,
      positions: Map.unmodifiable(positions),
    );
  }

  // ── Encoding helpers ──────────────────────────────────────────────────

  static String? _encodeStringList(List<String> items) {
    if (items.isEmpty) return null;
    return items.join(_listSeparator);
  }

  static List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return raw.split(_listSeparator).where((s) => s.isNotEmpty).toList();
  }

  static String? _encodeVolumes(List<StandardWork> volumes) {
    if (volumes.isEmpty) return null;
    return volumes.map((v) => v.apiVolumeId).join(_listSeparator);
  }

  static List<StandardWork> _decodeVolumes(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return raw
        .split(_listSeparator)
        .where((s) => s.isNotEmpty)
        .map(_volumeFromApiId)
        .toList();
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
