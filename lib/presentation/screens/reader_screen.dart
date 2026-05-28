import 'dart:async';

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

  /// If set, after the chapter loads we scroll so this verse is at the top.
  /// Used to resume a session where the user left off mid-chapter.
  final int? initialVerse;

  const ReaderScreen({
    super.key,
    required this.project,
    required this.volume,
    required this.bookApiId,
    required this.bookTitle,
    required this.initialChapter,
    this.initialVerse,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late int _currentChapter;
  int? _initialVerse;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listKey = GlobalKey();
  final Map<int, GlobalKey> _verseKeys = {};
  int? _topVerse;
  Timer? _saveDebounce;
  bool _pendingScrollToVerse = false;

  /// Captured during initState. Notifiers live in the ProviderContainer and
  /// outlive the widget, so we can use this reference safely from dispose,
  /// post-frame callbacks, and debounce timers — none of which can safely
  /// touch the widget's `ref`.
  late final StudyProjectsNotifier _projectsNotifier;
  DateTime _lastSaveAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _initialVerse = widget.initialVerse;
    _pendingScrollToVerse = _initialVerse != null && _initialVerse! > 1;
    _projectsNotifier = ref.read(studyProjectsProvider.notifier);
    _scrollController.addListener(_onScroll);
    _saveReadingPosition();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _saveDebounce?.cancel();
    // Final flush. Goes through the notifier so the home screen sees the
    // updated position when we pop back. Safe even mid-teardown because the
    // notifier reference is captured from the long-lived ProviderContainer.
    _saveReadingPosition();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _recomputeTopVerse();
  }

  void _recomputeTopVerse() {
    final listCtx = _listKey.currentContext;
    if (listCtx == null) return;
    final listBox = listCtx.findRenderObject() as RenderBox?;
    if (listBox == null || !listBox.attached) return;
    final viewportTop = listBox.localToGlobal(Offset.zero).dy;

    int? found;
    // Walk verses in numeric order; the first one whose top is at or below
    // the viewport top is the top-most fully visible verse.
    final entries = _verseKeys.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      if (top >= viewportTop - 1) {
        found = entry.key;
        break;
      }
    }
    if (found != null && found != _topVerse) {
      _topVerse = found;
      // During continuous scrolling the top verse changes every few frames
      // and a pure debounce would never fire — keep being cancelled and
      // re-scheduled. So we also save eagerly at most every 500ms, and use
      // the debounce only to capture the *final* position after the user
      // stops scrolling.
      final now = DateTime.now();
      if (now.difference(_lastSaveAt) >= const Duration(milliseconds: 500)) {
        _lastSaveAt = now;
        _saveReadingPosition();
      }
      _saveDebounce?.cancel();
      _saveDebounce = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        _lastSaveAt = DateTime.now();
        _saveReadingPosition();
      });
    }
  }

  void _saveReadingPosition() {
    final pos = ReadingPosition(
      volume: widget.volume,
      bookApiId: widget.bookApiId,
      bookTitle: widget.bookTitle,
      chapter: _currentChapter,
      verseNumber: _topVerse,
    );
    // Fire-and-forget via the captured notifier (NOT ref) so this is safe
    // from dispose, debounce callbacks, and post-frame callbacks alike.
    _projectsNotifier.updatePosition(widget.project, pos);
  }

  void _goToChapter(int chapter) {
    if (chapter < 1) return;
    _saveDebounce?.cancel();
    setState(() {
      _currentChapter = chapter;
      _topVerse = null;
      _verseKeys.clear();
      _initialVerse = null;
      _pendingScrollToVerse = false;
    });
    _scrollController.jumpTo(0);
    _saveReadingPosition();
    // Invalidate notes cache for new chapter
    ref.invalidate(chapterNotesProvider);
  }

  /// After the chapter renders, if we have an initial verse, scroll to it.
  /// `ListView.builder` is lazy, so a verse far down the chapter may not be
  /// built yet — we jump to an estimated offset to bring it into the build
  /// region, then a later frame will fine-tune with `ensureVisible`.
  void _maybeScrollToInitialVerse(int totalVerses) {
    if (!_pendingScrollToVerse) return;
    final verse = _initialVerse;
    if (verse == null || verse <= 1) {
      _pendingScrollToVerse = false;
      return;
    }
    final key = _verseKeys[verse];
    final ctx = key?.currentContext;
    if (ctx != null) {
      _pendingScrollToVerse = false;
      Scrollable.ensureVisible(
        ctx,
        duration: Duration.zero,
        alignment: 0,
      );
      return;
    }
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    if (maxScroll <= 0) return; // Layout not ready yet — retry next frame.
    final estimated =
        ((verse - 1) / totalVerses * maxScroll).clamp(0.0, maxScroll);
    _scrollController.jumpTo(estimated);
    // Keep _pendingScrollToVerse = true; next frame will retry and refine.
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

          // After this frame paints, resolve the top verse and (optionally)
          // scroll the user back to where they left off.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _maybeScrollToInitialVerse(chapter.verses.length);
            _recomputeTopVerse();
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  key: _listKey,
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
                    final key = _verseKeys.putIfAbsent(
                      verse.number,
                      () => GlobalKey(),
                    );

                    return KeyedSubtree(
                      key: key,
                      child: VerseWidget(
                        verse: verse,
                        notes: verseNotes,
                        textScale: textScale,
                        onTap: () => _showVerseActions(context, verse),
                      ),
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
