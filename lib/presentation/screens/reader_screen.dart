import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../controllers/verse_selection_controller.dart';
import '../providers/providers.dart';
import '../widgets/verse_action_sheet.dart';
import '../widgets/verse_widget.dart';

/// The core reading experience.
class ReaderScreen extends ConsumerStatefulWidget {
  final StudyProject project;
  final StandardWork volume;
  final String bookApiId;
  final String bookTitle;
  final int initialChapter;

  /// If set, after the chapter loads we scroll so this verse is at the top.
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
  final Map<int, List<GlobalKey>> _wordKeys = {};
  int? _topVerse;
  Timer? _saveDebounce;
  bool _pendingScrollToVerse = false;
  bool _inRestoration = false;

  late final StudyProjectsNotifier _projectsNotifier;
  DateTime _lastSaveAt = DateTime.fromMillisecondsSinceEpoch(0);

  // ── Verses cached for gesture callbacks ─────────────────────────────────
  Map<int, ScriptureVerse> _versesByNumber = {};

  // ── Gesture state ────────────────────────────────────────────────────────
  Offset? _pointerDownPos;
  bool _longPressRecognized = false;
  bool _isDragSelecting = false;
  OverlayEntry? _circleOverlay;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _initialVerse = widget.initialVerse;
    _pendingScrollToVerse = _initialVerse != null && _initialVerse! > 1;
    _topVerse = _initialVerse;
    _inRestoration = _pendingScrollToVerse;
    _projectsNotifier = ref.read(studyProjectsProvider.notifier);
    _scrollController.addListener(_onScroll);
    _saveReadingPosition();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _saveDebounce?.cancel();
    _removeLoadingCircle();
    _saveReadingPosition();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll & position ────────────────────────────────────────────────────

  void _onScroll() {
    if (_inRestoration) return;
    _recomputeTopVerse();
  }

  void _recomputeTopVerse() {
    final listCtx = _listKey.currentContext;
    if (listCtx == null) return;
    final listBox = listCtx.findRenderObject() as RenderBox?;
    if (listBox == null || !listBox.attached) return;
    final viewportTop = listBox.localToGlobal(Offset.zero).dy;

    int? found;
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
    _projectsNotifier.updatePosition(widget.project, pos);
  }

  void _goToChapter(int chapter) {
    if (chapter < 1) return;
    _saveDebounce?.cancel();
    ref.read(verseSelectionProvider.notifier).clearSelection();
    setState(() {
      _currentChapter = chapter;
      _topVerse = null;
      _verseKeys.clear();
      _wordKeys.clear();
      _versesByNumber = {};
      _initialVerse = null;
      _pendingScrollToVerse = false;
      _inRestoration = false;
    });
    _scrollController.jumpTo(0);
    _saveReadingPosition();
    ref.invalidate(chapterNotesProvider);
  }

  void _maybeScrollToInitialVerse(int totalVerses) {
    if (!_pendingScrollToVerse) {
      _finishRestoration();
      return;
    }
    final verse = _initialVerse;
    if (verse == null || verse <= 1) {
      _pendingScrollToVerse = false;
      _finishRestoration();
      return;
    }
    final key = _verseKeys[verse];
    final ctx = key?.currentContext;
    if (ctx != null) {
      _pendingScrollToVerse = false;
      Scrollable.ensureVisible(ctx, duration: Duration.zero, alignment: 0);
      _finishRestoration();
      return;
    }
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    if (maxScroll <= 0) return;
    final estimated =
        ((verse - 1) / totalVerses * maxScroll).clamp(0.0, maxScroll);
    _scrollController.jumpTo(estimated);
  }

  void _finishRestoration() {
    if (!_inRestoration) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inRestoration = false;
    });
  }

  // ── Word-key management ──────────────────────────────────────────────────

  List<GlobalKey> _getWordKeys(int verseNumber, int wordCount) {
    final existing = _wordKeys[verseNumber];
    if (existing != null && existing.length == wordCount) return existing;
    final keys = List.generate(wordCount, (_) => GlobalKey());
    _wordKeys[verseNumber] = keys;
    return keys;
  }

  // ── Hit testing ──────────────────────────────────────────────────────────

  /// Returns `(verseNumber, wordIndex)` for [globalPos], or null if not over
  /// any verse text.
  (int, int)? _hitTest(Offset globalPos) {
    for (final vEntry in _verseKeys.entries) {
      final vCtx = vEntry.value.currentContext;
      if (vCtx == null) continue;
      final vBox = vCtx.findRenderObject() as RenderBox?;
      if (vBox == null || !vBox.attached) continue;
      final vLocal = vBox.globalToLocal(globalPos);
      if (vLocal.dy < 0 || vLocal.dy > vBox.size.height) continue;

      final keys = _wordKeys[vEntry.key];
      if (keys == null || keys.isEmpty) return (vEntry.key, 0);

      int bestWord = 0;
      double bestDist = double.infinity;

      for (int i = 0; i < keys.length; i++) {
        final wCtx = keys[i].currentContext;
        if (wCtx == null) continue;
        final wBox = wCtx.findRenderObject() as RenderBox?;
        if (wBox == null || !wBox.attached) continue;
        final wLocal = wBox.globalToLocal(globalPos);

        // Direct hit (with small tolerance).
        if (wLocal.dx >= -4 &&
            wLocal.dx <= wBox.size.width + 4 &&
            wLocal.dy >= -4 &&
            wLocal.dy <= wBox.size.height + 4) {
          return (vEntry.key, i);
        }

        // Track nearest word for positions between words.
        final dist = _rectDistSq(
          Rect.fromLTWH(0, 0, wBox.size.width, wBox.size.height),
          wLocal,
        );
        if (dist < bestDist) {
          bestDist = dist;
          bestWord = i;
        }
      }

      return (vEntry.key, bestWord);
    }
    return null;
  }

  static double _rectDistSq(Rect r, Offset p) {
    final dx = p.dx < r.left
        ? r.left - p.dx
        : p.dx > r.right
            ? p.dx - r.right
            : 0.0;
    final dy = p.dy < r.top
        ? r.top - p.dy
        : p.dy > r.bottom
            ? p.dy - r.bottom
            : 0.0;
    return dx * dx + dy * dy;
  }

  // ── Loading circle overlay ───────────────────────────────────────────────

  void _showLoadingCircle(Offset position) {
    _removeLoadingCircle();
    _circleOverlay = OverlayEntry(
      builder: (_) => _LongPressCircle(position: position),
    );
    Overlay.of(context).insert(_circleOverlay!);
  }

  void _removeLoadingCircle() {
    _circleOverlay?.remove();
    _circleOverlay = null;
  }

  // ── Gesture handlers ─────────────────────────────────────────────────────

  void _onPointerDown(PointerDownEvent event) {
    _pointerDownPos = event.position;
    _longPressRecognized = false;
    _isDragSelecting = false;
    _showLoadingCircle(event.position);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_longPressRecognized) return; // let GestureDetector handle it
    final pos = _pointerDownPos;
    if (pos == null) return;
    // If the finger moves more than the scroll slop before long-press fires,
    // the scroll gesture will win — cancel the circle early.
    if ((event.position - pos).distance > 8) {
      _removeLoadingCircle();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    // Quick tap (no long-press recognized): tear down the circle so it
    // doesn't linger on screen waiting for an animation to finish.
    if (!_longPressRecognized) {
      _removeLoadingCircle();
      _pointerDownPos = null;
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_longPressRecognized) {
      _removeLoadingCircle();
      _pointerDownPos = null;
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _longPressRecognized = true;
    // Schedule the action sheet for the next frame. If a drag update arrives
    // on the same frame, _isDragSelecting will be true and we bail out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDragSelecting) return;
      _removeLoadingCircle();
      final hit = _hitTest(details.globalPosition);
      if (hit != null) {
        final verse = _versesByNumber[hit.$1];
        if (verse != null) _showVerseActions(context, verse);
      }
      _longPressRecognized = false;
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isDragSelecting) {
      _isDragSelecting = true;
      _removeLoadingCircle();
      // Set the anchor at the original press position.
      final anchor = _hitTest(_pointerDownPos ?? details.globalPosition);
      if (anchor != null) {
        ref
            .read(verseSelectionProvider.notifier)
            .startSelection(anchor.$1, anchor.$2);
      }
      setState(() {}); // disable scroll physics
    }
    // Update selection focus.
    final hit = _hitTest(details.globalPosition);
    if (hit != null) {
      ref
          .read(verseSelectionProvider.notifier)
          .updateFocus(hit.$1, hit.$2);
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _removeLoadingCircle();
    if (_isDragSelecting) {
      final selection = ref.read(verseSelectionProvider);
      if (selection.isSelecting) {
        _showHighlightColorPicker(selection);
      }
    }
    _isDragSelecting = false;
    _longPressRecognized = false;
    _pointerDownPos = null;
    if (mounted) setState(() {});
  }

  void _onLongPressCancel() {
    _removeLoadingCircle();
    _isDragSelecting = false;
    _longPressRecognized = false;
    _pointerDownPos = null;
    ref.read(verseSelectionProvider.notifier).clearSelection();
    if (mounted) setState(() {});
  }

  // ── Action sheet & color picker ──────────────────────────────────────────

  void _showVerseActions(BuildContext context, ScriptureVerse verse) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => VerseActionSheet(
        verse: verse,
        projectId: widget.project.id,
        volume: widget.volume,
        bookApiId: widget.bookApiId,
        chapter: _currentChapter,
        bookTitle: widget.bookTitle,
        onDone: () => ref.invalidate(chapterNotesProvider),
      ),
    );
  }

  void _showHighlightColorPicker(VerseSelectionState selection) {
    // whenComplete fires for every dismissal path — color pick, Cancel
    // button, scrim tap, system back. Centralizes selection cleanup so
    // phantom highlights can't persist after the sheet is gone.
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _HighlightColorPicker(
        onColorSelected: (color) {
          Navigator.pop(context);
          _saveHighlight(selection, color);
        },
        onCancel: () => Navigator.pop(context),
      ),
    ).whenComplete(() {
      if (mounted) {
        ref.read(verseSelectionProvider.notifier).clearSelection();
      }
    });
  }

  Future<void> _saveHighlight(
      VerseSelectionState selection, Color color) async {
    final startVerse = selection.startVerse;
    final endVerse = selection.endVerse;
    if (startVerse == null || endVerse == null) return;

    final repo = ref.read(noteRepositoryProvider);
    await repo.create(StudyNote(
      id: '',
      projectId: widget.project.id,
      volume: widget.volume,
      bookApiId: widget.bookApiId,
      chapter: _currentChapter,
      verseNumber: startVerse,
      endVerseNumber: startVerse == endVerse ? null : endVerse,
      startWordIndex: selection.startWord,
      endWordIndex: selection.endWord,
      type: NoteType.highlight,
      highlightColorValue: color.toARGB32(),
      createdAt: DateTime.now(),
    ));
    ref.invalidate(chapterNotesProvider);
  }

  // ── Build ────────────────────────────────────────────────────────────────

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

          // Expand multi-verse span notes into per-verse lookup.
          final notesByVerse = <int, List<StudyNote>>{};
          for (final note in notes) {
            final end = note.endVerseNumber ?? note.verseNumber;
            for (var v = note.verseNumber; v <= end; v++) {
              notesByVerse.putIfAbsent(v, () => []).add(note);
            }
          }

          // Cache verse-by-number for gesture callbacks.
          _versesByNumber = {for (final v in chapter.verses) v.number: v};

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _maybeScrollToInitialVerse(chapter.verses.length);
          });

          return Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onLongPressStart: _onLongPressStart,
                  onLongPressMoveUpdate: _onLongPressMoveUpdate,
                  onLongPressEnd: _onLongPressEnd,
                  onLongPressCancel: _onLongPressCancel,
                  child: Listener(
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: _onPointerCancel,
                    child: ListView.builder(
                      key: _listKey,
                      controller: _scrollController,
                      // Disable scroll during drag selection so the list
                      // doesn't fight the word-selection gesture.
                      physics: _isDragSelecting
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      padding:
                          const EdgeInsets.fromLTRB(24, 16, 24, 100),
                      itemCount: chapter.verses.length +
                          (chapter.summary != null ? 1 : 0),
                      itemBuilder: (context, index) {
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
                        final verseNotes =
                            notesByVerse[verse.number] ?? [];
                        final words = VerseWidget.tokenize(verse.text);
                        final wordKeys =
                            _getWordKeys(verse.number, words.length);
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
                            wordKeys: wordKeys,
                            onTapHighlight: () =>
                                _showVerseActions(context, verse),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
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
}

// ── Loading circle ────────────────────────────────────────────────────────

class _LongPressCircle extends StatefulWidget {
  final Offset position;

  const _LongPressCircle({required this.position});

  @override
  State<_LongPressCircle> createState() => _LongPressCircleState();
}

class _LongPressCircleState extends State<_LongPressCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: kLongPressTimeout,
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      left: widget.position.dx - 20,
      top: widget.position.dy - 20,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) => SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: _ctrl.value,
              strokeWidth: 3,
              color: colorScheme.primary,
              backgroundColor: colorScheme.primary.withAlpha(40),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Compact highlight color picker ────────────────────────────────────────

class _HighlightColorPicker extends StatelessWidget {
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onCancel;

  const _HighlightColorPicker({
    required this.onColorSelected,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Choose highlight color',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: HighlightColors.all.map((color) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () => onColorSelected(color),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.colorScheme.outlineVariant),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chapter nav ───────────────────────────────────────────────────────────

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
          top: BorderSide(
              color: theme.colorScheme.outlineVariant.withAlpha(80)),
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
