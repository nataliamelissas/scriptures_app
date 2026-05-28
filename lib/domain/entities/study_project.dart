import 'scripture.dart';

/// A named study project — the core differentiator of this app.
/// Each project maintains its own reading position and independent set of notes.
class StudyProject {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime lastOpenedAt;
  final DateTime? archivedAt;

  /// Standard work selected at creation. Used as the default destination
  /// when the project has no reading position yet.
  final StandardWork? defaultVolume;

  /// Where the user last left off in this project.
  final ReadingPosition? lastPosition;

  const StudyProject({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.lastOpenedAt,
    this.archivedAt,
    this.defaultVolume,
    this.lastPosition,
  });

  bool get isArchived => archivedAt != null;

  StudyProject copyWith({
    String? name,
    String? description,
    DateTime? lastOpenedAt,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    StandardWork? defaultVolume,
    ReadingPosition? lastPosition,
  }) {
    return StudyProject(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      defaultVolume: defaultVolume ?? this.defaultVolume,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }
}

/// Tracks where a user is reading within a study project.
class ReadingPosition {
  final StandardWork volume;
  final String bookApiId;
  final String bookTitle;
  final int chapter;

  /// Top fully-visible verse when the user last left the reader. Used to
  /// resume them exactly where they were rather than at the chapter start.
  final int? verseNumber;

  const ReadingPosition({
    required this.volume,
    required this.bookApiId,
    required this.bookTitle,
    required this.chapter,
    this.verseNumber,
  });
}

/// A user annotation tied to a specific project and verse.
enum NoteType { highlight, note, bookmark }

class StudyNote {
  final String id;
  final String projectId;
  final StandardWork volume;
  final String bookApiId;
  final int chapter;
  final int verseNumber;
  final NoteType type;
  final String? content; // text for notes, null for highlights/bookmarks
  final int? highlightColorValue; // ARGB int
  final DateTime createdAt;

  const StudyNote({
    required this.id,
    required this.projectId,
    required this.volume,
    required this.bookApiId,
    required this.chapter,
    required this.verseNumber,
    required this.type,
    this.content,
    this.highlightColorValue,
    required this.createdAt,
  });

  StudyNote copyWith({
    String? content,
    int? highlightColorValue,
  }) {
    return StudyNote(
      id: id,
      projectId: projectId,
      volume: volume,
      bookApiId: bookApiId,
      chapter: chapter,
      verseNumber: verseNumber,
      type: type,
      content: content ?? this.content,
      highlightColorValue: highlightColorValue ?? this.highlightColorValue,
      createdAt: createdAt,
    );
  }
}
