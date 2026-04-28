/// The five LDS standard works.
enum StandardWork {
  oldTestament,
  newTestament,
  bookOfMormon,
  doctrineAndCovenants,
  pearlOfGreatPrice;

  String get displayName => switch (this) {
        oldTestament => 'Old Testament',
        newTestament => 'New Testament',
        bookOfMormon => 'Book of Mormon',
        doctrineAndCovenants => 'Doctrine and Covenants',
        pearlOfGreatPrice => 'Pearl of Great Price',
      };

  /// ID used by OpenScriptureAPI.
  String get apiVolumeId => switch (this) {
        oldTestament => 'oldtestament',
        newTestament => 'newtestament',
        bookOfMormon => 'bookofmormon',
        doctrineAndCovenants => 'doctrineandcovenants',
        pearlOfGreatPrice => 'pearlofgreatprice',
      };

  /// Folder name in the local markdown scripture files.
  String get folderName => displayName;
}

/// A book within a standard work (e.g., "1 Nephi" in Book of Mormon).
class ScriptureBook {
  final String apiId; // e.g. "1nephi"
  final String title; // e.g. "1 Nephi"
  final StandardWork volume;

  const ScriptureBook({
    required this.apiId,
    required this.title,
    required this.volume,
  });
}

/// A single chapter with its verses and metadata.
class ScriptureChapter {
  final String bookApiId;
  final String bookTitle;
  final int number;
  final String? summary;
  final List<ScriptureVerse> verses;
  final String? nextChapterId;
  final String? prevChapterId;

  const ScriptureChapter({
    required this.bookApiId,
    required this.bookTitle,
    required this.number,
    this.summary,
    required this.verses,
    this.nextChapterId,
    this.prevChapterId,
  });
}

/// A single verse.
class ScriptureVerse {
  final int number;
  final String text;
  final List<FootNote> footNotes;

  const ScriptureVerse({
    required this.number,
    required this.text,
    this.footNotes = const [],
  });
}

/// A footnote attached to a verse with character-position anchors.
class FootNote {
  final int start;
  final int end;
  final String text;

  const FootNote({
    required this.start,
    required this.end,
    required this.text,
  });
}
