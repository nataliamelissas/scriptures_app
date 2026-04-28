import '../../domain/entities/scripture.dart';
import '../../domain/repositories/scripture_repository.dart';
import '../datasources/open_scripture_api.dart';
import '../datasources/local_scripture_source.dart';

/// Tries the API first, falls back to local markdown files.
class ScriptureRepositoryImpl implements ScriptureRepository {
  final OpenScriptureApi _api;
  final LocalScriptureSource _local;

  ScriptureRepositoryImpl({
    required OpenScriptureApi api,
    required LocalScriptureSource local,
  })  : _api = api,
        _local = local;

  @override
  Future<List<ScriptureBook>> getBooks(StandardWork volume) async {
    try {
      return await _api.fetchBooks(volume);
    } catch (_) {
      return _local.getBooks(volume);
    }
  }

  @override
  Future<ScriptureChapter> getChapter(
    StandardWork volume,
    String bookApiId,
    int chapterNumber,
  ) async {
    try {
      final chapter = await _api.fetchChapter(volume, bookApiId, chapterNumber);
      if (chapter.verses.isNotEmpty) return chapter;
    } catch (_) {
      // Fall through to local
    }

    // For local, we need the display title (folder name), not the API id.
    // Try to resolve it from the local book list.
    final localBooks = await _local.getBooks(volume);
    final match = localBooks.where((b) => b.apiId == bookApiId).toList();
    final bookTitle = match.isNotEmpty ? match.first.title : bookApiId;

    return _local.getChapter(volume, bookTitle, chapterNumber);
  }
}
