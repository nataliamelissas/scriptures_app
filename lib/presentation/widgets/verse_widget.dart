import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../../core/theme.dart';
import '../controllers/verse_selection_controller.dart';

/// Renders a single verse as a sequence of tappable word chips, supporting
/// per-word highlights, in-progress drag selection, and note indicators.
class VerseWidget extends ConsumerWidget {
  final ScriptureVerse verse;

  /// All notes whose span includes this verse (already expanded by the caller).
  final List<StudyNote> notes;

  final double textScale;

  /// Called when the user taps a word that already carries a highlight.
  final VoidCallback onTapHighlight;

  /// One [GlobalKey] per word token (split on whitespace). Created and owned
  /// by [ReaderScreen] so it can hit-test words during drag.
  final List<GlobalKey> wordKeys;

  const VerseWidget({
    super.key,
    required this.verse,
    required this.notes,
    required this.textScale,
    required this.onTapHighlight,
    required this.wordKeys,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final words = _tokenize(verse.text);

    // Only rebuild this widget when the selection range for THIS verse changes.
    final selRange = ref.watch(
      verseSelectionProvider
          .select((s) => s.rangeForVerse(verse.number, words.length)),
    );

    final hasNote = notes.any((n) => n.type == NoteType.note);
    final hasBookmark = notes.any((n) => n.type == NoteType.bookmark);
    final highlights = notes.where((n) => n.type == NoteType.highlight).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse number
          SizedBox(
            width: 28 * textScale,
            child: Text(
              '${verse.number}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11 * textScale,
              ),
            ),
          ),
          // Word chips + indicators
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 0,
                  runSpacing: 2,
                  children: List.generate(words.length, (i) {
                    final word = words[i];
                    final isLast = i == words.length - 1;
                    // Compute stored highlight once; selection overlay wins
                    // for chip color but tap-to-edit still keys off having
                    // an underlying stored highlight.
                    final storedHighlight = _highlightColorForWord(
                        i, words.length, highlights, verse.number);
                    final isInSelection = selRange != null &&
                        i >= selRange.$1 &&
                        i <= selRange.$2;
                    final Color? chipColor = isInSelection
                        ? theme.colorScheme.primary.withAlpha(80)
                        : storedHighlight;

                    Widget chip = Container(
                      key: wordKeys[i],
                      color: chipColor,
                      child: Text(
                        isLast ? word : '$word ',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 17 * textScale,
                        ),
                      ),
                    );

                    // Existing highlighted words open the action sheet on tap
                    // (no long-press required — tapping is enough).
                    if (storedHighlight != null) {
                      chip = GestureDetector(
                        onTap: onTapHighlight,
                        behavior: HitTestBehavior.opaque,
                        child: chip,
                      );
                    }

                    return chip;
                  }),
                ),
                if (hasNote || hasBookmark) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (hasBookmark)
                        Icon(
                          Icons.bookmark,
                          size: 14 * textScale,
                          color: theme.colorScheme.primary,
                        ),
                      if (hasNote) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 14 * textScale,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            notes
                                    .firstWhere((n) => n.type == NoteType.note)
                                    .content ??
                                '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11 * textScale,
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.tertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static List<String> _tokenize(String text) =>
      text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  /// Returns the highlight [Color] that covers [wordIndex] in this verse,
  /// considering multi-verse span geometry.
  static Color? _highlightColorForWord(
    int wordIndex,
    int wordCount,
    List<StudyNote> highlights,
    int verseNumber,
  ) {
    for (final note in highlights) {
      final (start, end) = _wordRangeForNote(note, verseNumber, wordCount);
      if (wordIndex >= start && wordIndex <= end) {
        return note.highlightColorValue != null
            ? Color(note.highlightColorValue!)
            : HighlightColors.yellow;
      }
    }
    return null;
  }

  /// Computes the highlighted word range `(startIdx, endIdx)` within
  /// [verseNumber] for a given [note], accounting for span position.
  static (int, int) _wordRangeForNote(
      StudyNote note, int verseNumber, int wordCount) {
    final endVerse = note.endVerseNumber ?? note.verseNumber;

    if (note.verseNumber == endVerse) {
      // Single-verse note (or legacy null = whole verse).
      return (note.startWordIndex ?? 0, note.endWordIndex ?? (wordCount - 1));
    }
    if (verseNumber == note.verseNumber) {
      // First verse of a multi-verse span.
      return (note.startWordIndex ?? 0, wordCount - 1);
    }
    if (verseNumber == endVerse) {
      // Last verse of a multi-verse span.
      return (0, note.endWordIndex ?? (wordCount - 1));
    }
    // Middle verse — fully highlighted.
    return (0, wordCount - 1);
  }

  /// Tokenizes [text] the same way as [_tokenize] — exposed so callers
  /// (e.g. [ReaderScreen]) can compute word counts without duplicating logic.
  static List<String> tokenize(String text) => _tokenize(text);
}
