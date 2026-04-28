import '../entities/scripture.dart';

abstract class ScriptureRepository {
  /// Get all books in a volume.
  Future<List<ScriptureBook>> getBooks(StandardWork volume);

  /// Get a specific chapter with verses.
  Future<ScriptureChapter> getChapter(
    StandardWork volume,
    String bookApiId,
    int chapterNumber,
  );
}
