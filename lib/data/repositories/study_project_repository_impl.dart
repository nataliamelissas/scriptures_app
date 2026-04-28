import 'package:uuid/uuid.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../../domain/repositories/study_project_repository.dart';
import '../datasources/app_database.dart';

class StudyProjectRepositoryImpl implements StudyProjectRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  StudyProjectRepositoryImpl({required AppDatabase db}) : _db = db;

  // ── Projects ──────────────────────────────────────────────────────────

  @override
  Future<List<StudyProject>> getAllProjects() async {
    final db = await _db.database;
    final rows = await db.query('projects', orderBy: 'last_opened_at DESC');
    return rows.map(_rowToProject).toList();
  }

  @override
  Future<StudyProject> createProject(String name, {String? description}) async {
    final db = await _db.database;
    final now = DateTime.now();
    final project = StudyProject(
      id: _uuid.v4(),
      name: name,
      description: description,
      createdAt: now,
      lastOpenedAt: now,
    );
    await db.insert('projects', _projectToRow(project));
    return project;
  }

  @override
  Future<void> updateProject(StudyProject project) async {
    final db = await _db.database;
    await db.update(
      'projects',
      _projectToRow(project),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  @override
  Future<void> deleteProject(String projectId) async {
    final db = await _db.database;
    // Notes cascade-delete via FK.
    await db.delete('projects', where: 'id = ?', whereArgs: [projectId]);
  }

  // ── Notes ─────────────────────────────────────────────────────────────

  @override
  Future<List<StudyNote>> getNotes(
    String projectId, {
    StandardWork? volume,
    String? bookApiId,
    int? chapter,
  }) async {
    final db = await _db.database;
    final where = StringBuffer('project_id = ?');
    final args = <Object>[projectId];

    if (volume != null) {
      where.write(' AND volume = ?');
      args.add(volume.apiVolumeId);
    }
    if (bookApiId != null) {
      where.write(' AND book_api_id = ?');
      args.add(bookApiId);
    }
    if (chapter != null) {
      where.write(' AND chapter = ?');
      args.add(chapter);
    }

    final rows = await db.query(
      'notes',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'verse_number ASC',
    );
    return rows.map(_rowToNote).toList();
  }

  @override
  Future<StudyNote> createNote(StudyNote note) async {
    final db = await _db.database;
    final withId = StudyNote(
      id: note.id.isEmpty ? _uuid.v4() : note.id,
      projectId: note.projectId,
      volume: note.volume,
      bookApiId: note.bookApiId,
      chapter: note.chapter,
      verseNumber: note.verseNumber,
      type: note.type,
      content: note.content,
      highlightColorValue: note.highlightColorValue,
      createdAt: note.createdAt,
    );
    await db.insert('notes', _noteToRow(withId));
    return withId;
  }

  @override
  Future<void> updateNote(StudyNote note) async {
    final db = await _db.database;
    await db.update(
      'notes',
      _noteToRow(note),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> deleteNote(String noteId) async {
    final db = await _db.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [noteId]);
  }

  // ── Mapping helpers ───────────────────────────────────────────────────

  StudyProject _rowToProject(Map<String, dynamic> row) {
    ReadingPosition? pos;
    if (row['last_volume'] != null) {
      pos = ReadingPosition(
        volume: _volumeFromApiId(row['last_volume'] as String),
        bookApiId: row['last_book_api_id'] as String,
        chapter: row['last_chapter'] as int,
      );
    }

    return StudyProject(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      lastOpenedAt: DateTime.parse(row['last_opened_at'] as String),
      lastPosition: pos,
    );
  }

  Map<String, dynamic> _projectToRow(StudyProject p) => {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'created_at': p.createdAt.toIso8601String(),
        'last_opened_at': p.lastOpenedAt.toIso8601String(),
        'last_volume': p.lastPosition?.volume.apiVolumeId,
        'last_book_api_id': p.lastPosition?.bookApiId,
        'last_chapter': p.lastPosition?.chapter,
      };

  StudyNote _rowToNote(Map<String, dynamic> row) => StudyNote(
        id: row['id'] as String,
        projectId: row['project_id'] as String,
        volume: _volumeFromApiId(row['volume'] as String),
        bookApiId: row['book_api_id'] as String,
        chapter: row['chapter'] as int,
        verseNumber: row['verse_number'] as int,
        type: NoteType.values.byName(row['type'] as String),
        content: row['content'] as String?,
        highlightColorValue: row['highlight_color'] as int?,
        createdAt: DateTime.parse(row['created_at'] as String),
      );

  Map<String, dynamic> _noteToRow(StudyNote n) => {
        'id': n.id,
        'project_id': n.projectId,
        'volume': n.volume.apiVolumeId,
        'book_api_id': n.bookApiId,
        'chapter': n.chapter,
        'verse_number': n.verseNumber,
        'type': n.type.name,
        'content': n.content,
        'highlight_color': n.highlightColorValue,
        'created_at': n.createdAt.toIso8601String(),
      };

  static StandardWork _volumeFromApiId(String id) => switch (id) {
        'oldtestament' => StandardWork.oldTestament,
        'newtestament' => StandardWork.newTestament,
        'bookofmormon' => StandardWork.bookOfMormon,
        'doctrineandcovenants' => StandardWork.doctrineAndCovenants,
        'pearlofgreatprice' => StandardWork.pearlOfGreatPrice,
        _ => StandardWork.bookOfMormon,
      };
}
