import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../data/datasources/app_database.dart';
import '../../data/datasources/local_scripture_source.dart';
import '../../data/datasources/open_scripture_api.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/repositories/scripture_repository_impl.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/scripture_repository.dart';

// ── Infrastructure singletons ───────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final openScriptureApiProvider =
    Provider<OpenScriptureApi>((ref) => OpenScriptureApi());

final localScriptureSourceProvider = Provider<LocalScriptureSource>(
  (ref) => LocalScriptureSource(
    basePath: LocalScriptureConfig.basePath,
  ),
);

// ── Repositories ────────────────────────────────────────────────────────

final scriptureRepositoryProvider = Provider<ScriptureRepository>((ref) {
  return ScriptureRepositoryImpl(
    api: ref.watch(openScriptureApiProvider),
    local: ref.watch(localScriptureSourceProvider),
  );
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

// ── Study Projects ──────────────────────────────────────────────────────

final studyProjectsProvider =
    AsyncNotifierProvider<StudyProjectsNotifier, List<StudyProject>>(
  StudyProjectsNotifier.new,
);

class StudyProjectsNotifier extends AsyncNotifier<List<StudyProject>> {
  @override
  Future<List<StudyProject>> build() async {
    return ref.read(projectRepositoryProvider).getAll();
  }

  Future<StudyProject> create(
    String name, {
    String? description,
    List<String> tags = const [],
    List<StandardWork> volumes = const [],
  }) async {
    final repo = ref.read(projectRepositoryProvider);
    final project = await repo.create(
      name,
      description: description,
      tags: tags,
      volumes: volumes,
    );
    ref.invalidateSelf();
    return project;
  }

  Future<void> delete(String projectId) async {
    await ref.read(projectRepositoryProvider).delete(projectId);
    ref.invalidateSelf();
  }

  Future<void> setArchived(String projectId, bool archived) async {
    await ref
        .read(projectRepositoryProvider)
        .setArchived(projectId, archived);
    ref.invalidateSelf();
    ref.invalidate(archivedProjectsProvider);
  }

  /// Edit name / description / tags. Pass null for any field to leave it
  /// unchanged.
  Future<void> updateProject(
    StudyProject project, {
    String? name,
    String? description,
    List<String>? tags,
  }) async {
    final updated = project.copyWith(
      name: name,
      description: description,
      tags: tags,
    );
    await ref.read(projectRepositoryProvider).update(updated);
    ref.invalidateSelf();
  }

  /// Add a standard work to the project. No-op if already present. The
  /// newly-added volume becomes the active volume if none was set.
  Future<StudyProject> addVolume(
    StudyProject project,
    StandardWork volume,
  ) async {
    if (project.volumes.contains(volume)) return project;
    final updated = project.copyWith(
      volumes: [...project.volumes, volume],
      activeVolume: project.activeVolume ?? volume,
    );
    await ref.read(projectRepositoryProvider).update(updated);
    ref.invalidateSelf();
    return updated;
  }

  /// Remove a standard work and any saved reading position for it.
  Future<void> removeVolume(
    StudyProject project,
    StandardWork volume,
  ) async {
    final newVolumes = project.volumes.where((v) => v != volume).toList();
    final newPositions =
        Map<StandardWork, ReadingPosition>.from(project.positions)
          ..remove(volume);
    final clearActive = project.activeVolume == volume;
    final updated = project.copyWith(
      volumes: newVolumes,
      positions: newPositions,
      activeVolume: clearActive ? null : project.activeVolume,
      clearActiveVolume: clearActive,
    );
    await ref.read(projectRepositoryProvider).update(updated);
    ref.invalidateSelf();
  }

  /// Save a reading position for the volume it belongs to. Also marks
  /// that volume as the active one and bumps lastOpenedAt.
  Future<void> updatePosition(
    StudyProject project,
    ReadingPosition position,
  ) async {
    final newPositions =
        Map<StandardWork, ReadingPosition>.from(project.positions);
    newPositions[position.volume] = position;
    // Ensure the volume is registered on the project.
    final newVolumes = project.volumes.contains(position.volume)
        ? project.volumes
        : [...project.volumes, position.volume];
    final updated = project.copyWith(
      lastOpenedAt: DateTime.now(),
      positions: newPositions,
      volumes: newVolumes,
      activeVolume: position.volume,
    );
    await ref.read(projectRepositoryProvider).update(updated);
    ref.invalidateSelf();
  }
}

/// Read-only list of archived projects (separate from the main list).
final archivedProjectsProvider = FutureProvider<List<StudyProject>>((ref) {
  return ref.read(projectRepositoryProvider).getArchived();
});

// ── Selected project ────────────────────────────────────────────────────

final selectedProjectProvider = StateProvider<StudyProject?>((ref) => null);

// ── Scripture data ──────────────────────────────────────────────────────

final booksProvider =
    FutureProvider.family<List<ScriptureBook>, StandardWork>((ref, volume) {
  return ref.read(scriptureRepositoryProvider).getBooks(volume);
});

/// Chapter overview (count + delineation) for a book, used by the chapter
/// picker. Record-keyed so the family gets value-equality for free.
final bookChaptersProvider =
    FutureProvider.family<BookChapters, ({StandardWork volume, String bookApiId})>(
  (ref, args) => ref
      .read(scriptureRepositoryProvider)
      .getBookChapters(args.volume, args.bookApiId),
);

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
  return ref.read(noteRepositoryProvider).getForChapter(
        params.projectId,
        params.volume,
        params.bookApiId,
        params.chapter,
      );
});

// ── Reader settings ─────────────────────────────────────────────────────

final textScaleProvider = StateProvider<double>((ref) => 1.0);
