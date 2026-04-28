import '../entities/study_project.dart';
import '../entities/scripture.dart';

abstract class StudyProjectRepository {
  Future<List<StudyProject>> getAllProjects();
  Future<StudyProject> createProject(String name, {String? description});
  Future<void> updateProject(StudyProject project);
  Future<void> deleteProject(String projectId);

  /// Get all notes for a project, optionally filtered to a specific chapter.
  Future<List<StudyNote>> getNotes(
    String projectId, {
    StandardWork? volume,
    String? bookApiId,
    int? chapter,
  });

  Future<StudyNote> createNote(StudyNote note);
  Future<void> updateNote(StudyNote note);
  Future<void> deleteNote(String noteId);
}
