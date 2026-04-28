import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_database.dart';
import '../../data/datasources/local_scripture_source.dart';
import '../../data/datasources/open_scripture_api.dart';
import '../../data/repositories/scripture_repository_impl.dart';
import '../../data/repositories/study_project_repository_impl.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../../domain/repositories/scripture_repository.dart';
import '../../domain/repositories/study_project_repository.dart';

// ── Infrastructure singletons ───────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final openScriptureApiProvider =
    Provider<OpenScriptureApi>((ref) => OpenScriptureApi());

final localScriptureSourceProvider = Provider<LocalScriptureSource>(
  (ref) => const LocalScriptureSource(
    basePath: r'***REMOVED***',
  ),
);

// ── Repositories ────────────────────────────────────────────────────────

final scriptureRepositoryProvider = Provider<ScriptureRepository>((ref) {
  return ScriptureRepositoryImpl(
    api: ref.watch(openScriptureApiProvider),
    local: ref.watch(localScriptureSourceProvider),
  );
});

final studyProjectRepositoryProvider =
    Provider<StudyProjectRepository>((ref) {
  return StudyProjectRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

// ── Study Projects ──────────────────────────────────────────────────────

final studyProjectsProvider =
    AsyncNotifierProvider<StudyProjectsNotifier, List<StudyProject>>(
  StudyProjectsNotifier.new,
);

class StudyProjectsNotifier extends AsyncNotifier<List<StudyProject>> {
  @override
  Future<List<StudyProject>> build() async {
    return ref.read(studyProjectRepositoryProvider).getAllProjects();
  }

  Future<StudyProject> create(String name, {String? description}) async {
    final repo = ref.read(studyProjectRepositoryProvider);
    final project = await repo.createProject(name, description: description);
    ref.invalidateSelf();
    return project;
  }

  Future<void> delete(String projectId) async {
    await ref.read(studyProjectRepositoryProvider).deleteProject(projectId);
    ref.invalidateSelf();
  }

  Future<void> updatePosition(
    StudyProject project,
    ReadingPosition position,
  ) async {
    final updated = project.copyWith(
      lastOpenedAt: DateTime.now(),
      lastPosition: position,
    );
    await ref.read(studyProjectRepositoryProvider).updateProject(updated);
    ref.invalidateSelf();
  }
}

// ── Selected project ────────────────────────────────────────────────────

final selectedProjectProvider = StateProvider<StudyProject?>((ref) => null);

// ── Scripture data ──────────────────────────────────────────────────────

final booksProvider =
    FutureProvider.family<List<ScriptureBook>, StandardWork>((ref, volume) {
  return ref.read(scriptureRepositoryProvider).getBooks(volume);
});

/// Parameter for loading a chapter.
class ChapterParams {
  final StandardWork volume;
  final String bookApiId;
  final int chapter;

  const ChapterParams({
    required this.volume,
    required this.bookApiId,
    required this.chapter,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterParams &&
          volume == other.volume &&
          bookApiId == other.bookApiId &&
          chapter == other.chapter;

  @override
  int get hashCode => Object.hash(volume, bookApiId, chapter);
}

final chapterProvider =
    FutureProvider.family<ScriptureChapter, ChapterParams>((ref, params) {
  return ref.read(scriptureRepositoryProvider).getChapter(
        params.volume,
        params.bookApiId,
        params.chapter,
      );
});

// ── Notes for current chapter ───────────────────────────────────────────

class ChapterNotesParams {
  final String projectId;
  final StandardWork volume;
  final String bookApiId;
  final int chapter;

  const ChapterNotesParams({
    required this.projectId,
    required this.volume,
    required this.bookApiId,
    required this.chapter,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterNotesParams &&
          projectId == other.projectId &&
          volume == other.volume &&
          bookApiId == other.bookApiId &&
          chapter == other.chapter;

  @override
  int get hashCode => Object.hash(projectId, volume, bookApiId, chapter);
}

final chapterNotesProvider =
    FutureProvider.family<List<StudyNote>, ChapterNotesParams>((ref, params) {
  return ref.read(studyProjectRepositoryProvider).getNotes(
        params.projectId,
        volume: params.volume,
        bookApiId: params.bookApiId,
        chapter: params.chapter,
      );
});

// ── Reader settings ─────────────────────────────────────────────────────

final textScaleProvider = StateProvider<double>((ref) => 1.0);
