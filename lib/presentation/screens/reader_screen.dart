import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../providers/providers.dart';
import '../widgets/verse_widget.dart';
import '../widgets/verse_action_sheet.dart';

/// The core reading experience.
class ReaderScreen extends ConsumerStatefulWidget {
  final StudyProject project;
  final StandardWork volume;
  final String bookApiId;
  final String bookTitle;
  final int initialChapter;

  const ReaderScreen({
    super.key,
    required this.project,
    required this.volume,
    required this.bookApiId,
    required this.bookTitle,
    required this.initialChapter,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late int _currentChapter;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _saveReadingPosition();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _saveReadingPosition() {
    final pos = ReadingPosition(
      volume: widget.volume,
      bookApiId: widget.bookApiId,
      chapter: _currentChapter,
    );
    ref
        .read(studyProjectsProvider.notifier)
        .updatePosition(widget.project, pos);
  }

  void _goToChapter(int chapter) {
    if (chapter < 1) return;
    setState(() => _currentChapter = chapter);
    _scrollController.jumpTo(0);
    _saveReadingPosition();
    // Invalidate notes cache for new chapter
    ref.invalidate(chapterNotesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = ref.watch(textScaleProvider);

    final chapterAsync = ref.watch(chapterProvider(ChapterParams(
      volume: widget.volume,
      bookApiId: widget.bookApiId,
      chapter: _currentChapter,
    )));

    final notesAsync = ref.watch(chapterNotesProvider(ChapterNotesParams(
      projectId: widget.project.id,
      volume: widget.volume,
      bookApiId: widget.bookApiId,
      chapter: _currentChapter,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bookTitle} $_currentChapter'),
        actions: [
          // Text size controls
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: textScale > 0.7
                ? () => ref.read(textScaleProvider.notifier).state =
                    (textScale - 0.1).clamp(0.7, 1.6)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: textScale < 1.6
                ? () => ref.read(textScaleProvider.notifier).state =
                    (textScale + 0.1).clamp(0.7, 1.6)
                : null,
          ),
        ],
      ),
      body: chapterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading chapter\n$e')),
        data: (chapter) {
          final notes = notesAsync.valueOrNull ?? [];

          // Build a map: verse number -> list of notes
          final notesByVerse = <int, List<StudyNote>>{};
          for (final note in notes) {
            notesByVerse.putIfAbsent(note.verseNumber, () => []).add(note);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                  itemCount:
                      chapter.verses.length + (chapter.summary != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Chapter summary header
                    if (chapter.summary != null && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          chapter.summary!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 14 * textScale,
                          ),
                        ),
                      );
                    }

                    final verseIndex =
                        chapter.summary != null ? index - 1 : index;
                    final verse = chapter.verses[verseIndex];
                    final verseNotes = notesByVerse[verse.number] ?? [];

                    return VerseWidget(
                      verse: verse,
                      notes: verseNotes,
                      textScale: textScale,
                      onTap: () => _showVerseActions(context, verse),
                    );
                  },
                ),
              ),
              // Bottom navigation bar for prev/next chapter
              _ChapterNav(
                chapter: chapter,
                onPrev: chapter.prevChapterId != null || _currentChapter > 1
                    ? () => _goToChapter(_currentChapter - 1)
                    : null,
                onNext: chapter.nextChapterId != null
                    ? () => _goToChapter(_currentChapter + 1)
                    : null,
                currentChapter: _currentChapter,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVerseActions(BuildContext context, ScriptureVerse verse) {
    showModalBottomSheet(
      context: context,
      builder: (_) => VerseActionSheet(
        verse: verse,
        projectId: widget.project.id,
        volume: widget.volume,
        bookApiId: widget.bookApiId,
        chapter: _currentChapter,
        onDone: () {
          // Refresh notes
          ref.invalidate(chapterNotesProvider);
        },
      ),
    );
  }
}

class _ChapterNav extends StatelessWidget {
  final ScriptureChapter chapter;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final int currentChapter;

  const _ChapterNav({
    required this.chapter,
    this.onPrev,
    this.onNext,
    required this.currentChapter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: onPrev,
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              label: const Text('Previous'),
            ),
            Text(
              'Chapter $currentChapter',
              style: theme.textTheme.bodySmall,
            ),
            TextButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              label: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
