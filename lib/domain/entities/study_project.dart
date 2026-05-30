import 'scripture.dart';

/// A named study project — the core differentiator of this app.
/// Each project maintains its own per-volume reading positions and
/// independent set of notes.
class StudyProject {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime lastOpenedAt;
  final DateTime? archivedAt;

  /// User-defined tags (e.g. "hope", "faith"). Each capped at 15 chars
  /// at the UI layer.
  final List<String> tags;

  /// Standard works the user has added to this study project.
  final List<StandardWork> volumes;

  /// The last-touched volume — used to know where to return when opening
  /// the project. Null if no reading has happened yet.
  final StandardWork? activeVolume;

  /// Per-volume reading positions. A volume is only present here once
  /// the user has actually read from it.
  final Map<StandardWork, ReadingPosition> positions;

  const StudyProject({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.lastOpenedAt,
    this.archivedAt,
    this.tags = const [],
    this.volumes = const [],
    this.activeVolume,
    this.positions = const {},
  });

  bool get isArchived => archivedAt != null;

  /// Position in the currently-active volume, if any.
  ReadingPosition? get activePosition =>
      activeVolume == null ? null : positions[activeVolume];

  StudyProject copyWith({
    String? name,
    String? description,
    DateTime? lastOpenedAt,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    List<String>? tags,
    List<StandardWork>? volumes,
    StandardWork? activeVolume,
    bool clearActiveVolume = false,
    Map<StandardWork, ReadingPosition>? positions,
  }) {
    return StudyProject(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      tags: tags ?? this.tags,
      volumes: volumes ?? this.volumes,
      activeVolume:
          clearActiveVolume ? null : (activeVolume ?? this.activeVolume),
      positions: positions ?? this.positions,
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

  /// For multi-verse highlight spans. Null means the note covers only
  /// [verseNumber]. When set, all verses in [verseNumber]..[endVerseNumber]
  /// are included; intermediate verses are fully highlighted.
  final int? endVerseNumber;

  /// Word index (0-based, split on whitespace) where a highlight starts
  /// within [verseNumber]. Null means start of verse.
  final int? startWordIndex;

  /// Word index where a highlight ends within [endVerseNumber] (or
  /// [verseNumber] for single-verse notes). Null means end of verse.
  final int? endWordIndex;

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
    this.endVerseNumber,
    this.startWordIndex,
    this.endWordIndex,
    required this.createdAt,
  });

  StudyNote copyWith({
    int? verseNumber,
    String? content,
    int? highlightColorValue,
    int? endVerseNumber,
    int? startWordIndex,
    int? endWordIndex,
  }) {
    return StudyNote(
      id: id,
      projectId: projectId,
      volume: volume,
      bookApiId: bookApiId,
      chapter: chapter,
      verseNumber: verseNumber ?? this.verseNumber,
      type: type,
      content: content ?? this.content,
      highlightColorValue: highlightColorValue ?? this.highlightColorValue,
      endVerseNumber: endVerseNumber ?? this.endVerseNumber,
      startWordIndex: startWordIndex ?? this.startWordIndex,
      endWordIndex: endWordIndex ?? this.endWordIndex,
      createdAt: createdAt,
    );
  }
}
