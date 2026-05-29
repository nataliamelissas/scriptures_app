import '../entities/scripture.dart';
import '../entities/study_project.dart';

abstract class ProjectRepository {
  /// All non-archived projects, most-recently-opened first.
  Future<List<StudyProject>> getAll();

  /// Archived projects, most-recently-archived first.
  Future<List<StudyProject>> getArchived();

  Future<StudyProject> create(
    String name, {
    String? description,
    List<String> tags,
    List<StandardWork> volumes,
  });
  Future<void> update(StudyProject project);
  Future<void> setArchived(String projectId, bool archived);
  Future<void> delete(String projectId);
}
