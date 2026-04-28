import 'package:flutter/material.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../../core/theme.dart';

/// Renders a single verse with optional highlight background and note indicator.
class VerseWidget extends StatelessWidget {
  final ScriptureVerse verse;
  final List<StudyNote> notes;
  final double textScale;
  final VoidCallback onTap;

  const VerseWidget({
    super.key,
    required this.verse,
    required this.notes,
    required this.textScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine highlight color if any highlight notes exist
    final highlight = notes.where((n) => n.type == NoteType.highlight).toList();
    final hasNote = notes.any((n) => n.type == NoteType.note);
    final hasBookmark = notes.any((n) => n.type == NoteType.bookmark);

    Color? bgColor;
    if (highlight.isNotEmpty) {
      final colorValue = highlight.first.highlightColorValue;
      bgColor = colorValue != null
          ? Color(colorValue)
          : HighlightColors.yellow;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
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
            // Verse text + indicators
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    verse.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 17 * textScale,
                    ),
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
      ),
    );
  }
}
