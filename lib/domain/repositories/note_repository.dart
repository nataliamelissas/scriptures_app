import '../entities/scripture.dart';
import '../entities/study_project.dart';

abstract class NoteRepository {
  /// Get notes for a project, optionally filtered to a specific chapter.
  Future<List<StudyNote>> getForChapter(
    String projectId,
    StandardWork volume,
    String bookApiId,
    int chapter,
  );

  Future<StudyNote> create(StudyNote note);
  Future<void> update(StudyNote note);
  Future<void> delete(String noteId);
}
