import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/entities/scripture.dart';

/// Parses the local Obsidian-format markdown scripture files as a fallback
/// when the API is unavailable.
///
/// File format per chapter:
/// ```
/// # 1 Nephi 1
/// #scriptures/book-of-mormon
///
/// 1 Verse text here... ^1nephi-1-1
///
/// 2 Next verse text... ^1nephi-1-2
/// ```
class LocalScriptureSource {
  final String basePath;

  /// [basePath] is the root folder containing volume subfolders.
  /// e.g. "***REMOVED***"
  const LocalScriptureSource({required this.basePath});

  /// Lists book folders within a volume folder.
  Future<List<ScriptureBook>> getBooks(StandardWork volume) async {
    final volumeDir = Directory(p.join(basePath, volume.folderName));
    if (!await volumeDir.exists()) return [];

    final entries = await volumeDir.list().toList();
    final books = <ScriptureBook>[];

    for (final entry in entries) {
      if (entry is Directory) {
        final name = p.basename(entry.path);
        books.add(ScriptureBook(
          apiId: _toApiId(name),
          title: name,
          volume: volume,
        ));
      }
    }

    // Sort alphabetically for consistency
    books.sort((a, b) => a.title.compareTo(b.title));
    return books;
  }

  /// Parses a chapter markdown file into a [ScriptureChapter].
  Future<ScriptureChapter> getChapter(
    StandardWork volume,
    String bookTitle,
    int chapterNumber,
  ) async {
    // D&C has a nested structure: "Doctrine and Covenants/Doctrine and Covenants/D&C 1.md"
    final chapterFile = _resolveChapterFile(volume, bookTitle, chapterNumber);

    if (!await chapterFile.exists()) {
      return ScriptureChapter(
        bookApiId: _toApiId(bookTitle),
        bookTitle: bookTitle,
        number: chapterNumber,
        verses: [],
      );
    }

    final content = await chapterFile.readAsString();
    final lines = content.split('\n');

    final verses = <ScriptureVerse>[];
    // Verse pattern: starts with a number, then space, then text, optionally ending with ^anchor
    final verseRegex = RegExp(r'^(\d+)\s+(.+?)(?:\s+\^[\w-]+)?$');

    for (final line in lines) {
      final match = verseRegex.firstMatch(line.trim());
      if (match != null) {
        verses.add(ScriptureVerse(
          number: int.parse(match.group(1)!),
          text: match.group(2)!,
        ));
      }
    }

    return ScriptureChapter(
      bookApiId: _toApiId(bookTitle),
      bookTitle: bookTitle,
      number: chapterNumber,
      verses: verses,
    );
  }

  /// Count chapter files in a book folder.
  Future<int> getChapterCount(StandardWork volume, String bookTitle) async {
    final bookDir = _resolveBookDir(volume, bookTitle);
    if (!await bookDir.exists()) return 0;

    final files = await bookDir
        .list()
        .where((e) => e is File && e.path.endsWith('.md'))
        .toList();

    // Subtract 1 for the index file (e.g. "1 Nephi.md")
    final chapterFiles =
        files.where((f) => RegExp(r'\d+\.md$').hasMatch(f.path));
    return chapterFiles.length;
  }

  Directory _resolveBookDir(StandardWork volume, String bookTitle) {
    if (volume == StandardWork.doctrineAndCovenants) {
      // D&C: "Doctrine and Covenants/Doctrine and Covenants/"
      return Directory(
          p.join(basePath, volume.folderName, 'Doctrine and Covenants'));
    }
    return Directory(p.join(basePath, volume.folderName, bookTitle));
  }

  File _resolveChapterFile(
    StandardWork volume,
    String bookTitle,
    int chapterNumber,
  ) {
    final dir = _resolveBookDir(volume, bookTitle);
    final fileName = '$bookTitle $chapterNumber.md';
    return File(p.join(dir.path, fileName));
  }

  /// Convert display title to API-style ID: "1 Nephi" -> "1nephi"
  static String _toApiId(String title) {
    return title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
