import 'scripture.dart';

/// A named study project — the core differentiator of this app.
/// Each project maintains its own reading position and independent set of notes.
class StudyProject {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime lastOpenedAt;

  /// Where the user last left off in this project.
  final ReadingPosition? lastPosition;

  const StudyProject({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.lastOpenedAt,
    this.lastPosition,
  });

  StudyProject copyWith({
    String? name,
    String? description,
    DateTime? lastOpenedAt,
    ReadingPosition? lastPosition,
  }) {
    return StudyProject(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }
}

/// Tracks where a user is reading within a study project.
class ReadingPosition {
  final StandardWork volume;
  final String bookApiId;
  final int chapter;

  const ReadingPosition({
    required this.volume,
    required this.bookApiId,
    required this.chapter,
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
