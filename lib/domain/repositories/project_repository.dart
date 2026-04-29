import '../entities/study_project.dart';

abstract class ProjectRepository {
  Future<List<StudyProject>> getAll();
  Future<StudyProject> create(String name, {String? description});
  Future<void> update(StudyProject project);
  Future<void> delete(String projectId);
}
