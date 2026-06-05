import '../entities/scripture.dart';

abstract class ScriptureRepository {
  /// Get all books in a volume.
  Future<List<ScriptureBook>> getBooks(StandardWork volume);

  /// Get a book's chapter overview (count + delineation) for the chapter picker.
  Future<BookChapters> getBookChapters(StandardWork volume, String bookApiId);

  /// Get a specific chapter with verses.
  Future<ScriptureChapter> getChapter(
    StandardWork volume,
    String bookApiId,
    int chapterNumber,
  );
}
