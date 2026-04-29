import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/app_database.dart';

class NoteRepositoryImpl implements NoteRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  NoteRepositoryImpl({required AppDatabase db}) : _db = db;

  @override
  Future<List<StudyNote>> getForChapter(
    String projectId,
    StandardWork volume,
    String bookApiId,
    int chapter,
  ) async {
    final query = _db.select(_db.notes)
      ..where((n) =>
          n.projectId.equals(projectId) &
          n.volume.equals(volume.apiVolumeId) &
          n.bookApiId.equals(bookApiId) &
          n.chapter.equals(chapter))
      ..orderBy([(n) => OrderingTerm.asc(n.verseNumber)]);

    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<StudyNote> create(StudyNote note) async {
    final id = note.id.isEmpty ? _uuid.v4() : note.id;

    await _db.into(_db.notes).insert(NotesCompanion.insert(
          id: id,
          projectId: note.projectId,
          volume: note.volume.apiVolumeId,
          bookApiId: note.bookApiId,
          chapter: note.chapter,
          verseNumber: note.verseNumber,
          type: note.type.name,
          content: Value(note.content),
          highlightColor: Value(note.highlightColorValue),
          createdAt: note.createdAt,
        ));

    return StudyNote(
      id: id,
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
  }

  @override
  Future<void> update(StudyNote note) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(note.id))).write(
      NotesCompanion(
        content: Value(note.content),
        highlightColor: Value(note.highlightColorValue),
      ),
    );
  }

  @override
  Future<void> delete(String noteId) async {
    await (_db.delete(_db.notes)..where((n) => n.id.equals(noteId))).go();
  }

  // ── Mapping ───────────────────────────────────────────────────────────

  static StudyNote _toEntity(Note row) => StudyNote(
        id: row.id,
        projectId: row.projectId,
        volume: _volumeFromApiId(row.volume),
        bookApiId: row.bookApiId,
        chapter: row.chapter,
        verseNumber: row.verseNumber,
        type: NoteType.values.byName(row.type),
        content: row.content,
        highlightColorValue: row.highlightColor,
        createdAt: row.createdAt,
      );

  static StandardWork _volumeFromApiId(String id) => switch (id) {
        'oldtestament' => StandardWork.oldTestament,
        'newtestament' => StandardWork.newTestament,
        'bookofmormon' => StandardWork.bookOfMormon,
        'doctrineandcovenants' => StandardWork.doctrineAndCovenants,
        'pearlofgreatprice' => StandardWork.pearlOfGreatPrice,
        _ => StandardWork.bookOfMormon,
      };
}
