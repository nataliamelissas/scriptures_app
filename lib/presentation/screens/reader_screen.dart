import 'dart:async';
import 'dart:math' as math;

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

  // ── Verses & notes cached for gesture callbacks ──────────────────────────
  Map<int, ScriptureVerse> _versesByNumber = {};
  Map<int, List<StudyNote>> _notesByVerse = {};

  // ── Gesture state ────────────────────────────────────────────────────────
  Offset? _pointerDownPos;
  bool _longPressRecognized = false;
  bool _isDragSelecting = false;
  bool _isMouseDown = false;
  OverlayEntry? _circleOverlay;

  // ── Handle + popup overlays ──────────────────────────────────────────────
  OverlayEntry? _startHandleOverlay;
  OverlayEntry? _endHandleOverlay;
  OverlayEntry? _notePopupOverlay;

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
    _removeHandleOverlays();
    _removeNotePopup();
    _saveReadingPosition();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll & position ────────────────────────────────────────────────────

  void _onScroll() {
    if (_inRestoration) return;
    _recomputeTopVerse();
    // Reposition handles when the list scrolls.
    final active = ref.read(verseSelectionProvider).activeHighlight;
    if (active != null) _updateHandleOverlays(active);
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
    _removeHandleOverlays();
    _removeNotePopup();
    setState(() {
      _currentChapter = chapter;
      _topVerse = null;
      _verseKeys.clear();
      _wordKeys.clear();
      _versesByNumber = {};
      _notesByVerse = {};
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

  // ── Note lookup helpers ──────────────────────────────────────────────────

  /// Returns the highlight [StudyNote] that covers [wordIndex] in [verseNum],
  /// or null if no highlight does.
  StudyNote? _highlightNoteForWord(int verseNum, int wordIndex) {
    final highlights = (_notesByVerse[verseNum] ?? [])
        .where((n) => n.type == NoteType.highlight)
        .toList();
    final wordCount =
        VerseWidget.tokenize(_versesByNumber[verseNum]?.text ?? '').length;
    for (final n in highlights) {
      final (s, e) = VerseWidget.wordRangeForNote(n, verseNum, wordCount);
      if (wordIndex >= s && wordIndex <= e) return n;
    }
    return null;
  }

  /// Returns true if [hit] (verse, word) falls within [note]'s highlight span.
  bool _isWordInNote((int, int) hit, StudyNote note) {
    final endVerse = note.endVerseNumber ?? note.verseNumber;
    if (hit.$1 < note.verseNumber || hit.$1 > endVerse) return false;
    final wordCount =
        VerseWidget.tokenize(_versesByNumber[hit.$1]?.text ?? '').length;
    final (s, e) = VerseWidget.wordRangeForNote(note, hit.$1, wordCount);
    return hit.$2 >= s && hit.$2 <= e;
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

  // ── Handle overlays ──────────────────────────────────────────────────────

  void _updateHandleOverlays(StudyNote note) {
    _removeHandleOverlays();

    final startWordIdx = note.startWordIndex ?? 0;
    final endVerse = note.endVerseNumber ?? note.verseNumber;
    final endWords = VerseWidget.tokenize(_versesByNumber[endVerse]?.text ?? '');
    final endWordIdx =
        note.endWordIndex ?? (endWords.isEmpty ? 0 : endWords.length - 1);

    final startKey = _wordKeys[note.verseNumber]?[startWordIdx];
    final endKey = _wordKeys[endVerse]?[endWordIdx];

    // Only show handles when both word containers are currently mounted.
    if (startKey?.currentContext == null || endKey?.currentContext == null) return;

    _startHandleOverlay = OverlayEntry(
      builder: (_) => _HighlightHandle(
        wordKey: startKey!,
        isStart: true,
        onDragStart: () =>
            ref.read(verseSelectionProvider.notifier).beginHandleDrag(note),
        onDragUpdate: (pos) => _onHandleDragUpdate(pos, isStart: true),
        onDragEnd: _onHandleDragEnd,
      ),
    );
    _endHandleOverlay = OverlayEntry(
      builder: (_) => _HighlightHandle(
        wordKey: endKey!,
        isStart: false,
        onDragStart: () =>
            ref.read(verseSelectionProvider.notifier).beginHandleDrag(note),
        onDragUpdate: (pos) => _onHandleDragUpdate(pos, isStart: false),
        onDragEnd: _onHandleDragEnd,
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_startHandleOverlay!);
    overlay.insert(_endHandleOverlay!);
  }

  void _removeHandleOverlays() {
    _startHandleOverlay?.remove();
    _startHandleOverlay = null;
    _endHandleOverlay?.remove();
    _endHandleOverlay = null;
  }

  void _onHandleDragUpdate(Offset globalPos, {required bool isStart}) {
    final hit = _hitTest(globalPos);
    if (hit == null) return;
    final s = ref.read(verseSelectionProvider);
    final note = s.activeHighlight;
    if (note == null) return;

    // Validate: start must not pass end and vice versa.
    if (isStart) {
      final endV = s.liveEndVerse ?? note.endVerseNumber ?? note.verseNumber;
      final endW = s.liveEndWord ?? note.endWordIndex ?? 999;
      if (hit.$1 > endV || (hit.$1 == endV && hit.$2 > endW)) return;
    } else {
      final startV = s.liveStartVerse ?? note.verseNumber;
      final startW = s.liveStartWord ?? note.startWordIndex ?? 0;
      if (hit.$1 < startV || (hit.$1 == startV && hit.$2 < startW)) return;
    }

    ref
        .read(verseSelectionProvider.notifier)
        .updateHandleDrag(hit.$1, hit.$2, isStartHandle: isStart);
    _startHandleOverlay?.markNeedsBuild();
    _endHandleOverlay?.markNeedsBuild();
  }

  Future<void> _onHandleDragEnd() async {
    final s = ref.read(verseSelectionProvider);
    final note = s.activeHighlight;
    if (note == null) return;

    final newStartVerse = s.liveStartVerse ?? note.verseNumber;
    final newEndVerse = s.liveEndVerse ?? note.endVerseNumber ?? note.verseNumber;
    final updated = note.copyWith(
      verseNumber: newStartVerse,
      startWordIndex: s.liveStartWord,
      endWordIndex: s.liveEndWord,
      endVerseNumber: newStartVerse == newEndVerse ? null : newEndVerse,
    );

    await ref.read(noteRepositoryProvider).update(updated);
    ref.invalidate(chapterNotesProvider);
    ref.read(verseSelectionProvider.notifier).endHandleDrag();
    ref.read(verseSelectionProvider.notifier).setActiveHighlight(updated);
    _updateHandleOverlays(updated);
  }

  // ── Note-only popup ──────────────────────────────────────────────────────

  void _showNotePopup(StudyNote note, Offset anchorGlobal) {
    _removeNotePopup();
    _notePopupOverlay = OverlayEntry(
      builder: (ctx) => _NoteEditPopup(
        note: note,
        anchorGlobal: anchorGlobal,
        onSave: (text) async {
          final updated = note.copyWith(content: text.isEmpty ? null : text);
          await ref.read(noteRepositoryProvider).update(updated);
          ref.invalidate(chapterNotesProvider);
          _removeNotePopup();
        },
        onDismiss: _removeNotePopup,
      ),
    );
    Overlay.of(context).insert(_notePopupOverlay!);
  }

  void _removeNotePopup() {
    _notePopupOverlay?.remove();
    _notePopupOverlay = null;
  }

  // ── Gesture handlers ─────────────────────────────────────────────────────

  void _onPointerDown(PointerDownEvent event) {
    // Dismiss note popup on any tap outside it.
    if (_notePopupOverlay != null) {
      _removeNotePopup();
      return;
    }

    // Tap-away: clear active highlight + handles if tap is outside the span.
    final active = ref.read(verseSelectionProvider).activeHighlight;
    if (active != null) {
      final hit = _hitTest(event.position);
      if (hit == null || !_isWordInNote(hit, active)) {
        ref.read(verseSelectionProvider.notifier).clearActiveHighlight();
        _removeHandleOverlays();
      }
    }

    _pointerDownPos = event.position;
    _longPressRecognized = false;
    _isDragSelecting = false;

    if (event.kind == PointerDeviceKind.mouse) {
      _isMouseDown = true;
      // No loading circle for mouse.
    } else {
      _showLoadingCircle(event.position);
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.kind == PointerDeviceKind.mouse && _isMouseDown) {
      _handleMouseDragMove(event.position);
      return;
    }
    if (_longPressRecognized) return; // let GestureDetector handle it
    final pos = _pointerDownPos;
    if (pos == null) return;
    // If the finger moves more than the scroll slop before long-press fires,
    // the scroll gesture will win — cancel the circle early.
    if ((event.position - pos).distance > 8) {
      _removeLoadingCircle();
    }
  }

  void _handleMouseDragMove(Offset pos) {
    final down = _pointerDownPos;
    if (down == null) return;
    if (!_isDragSelecting && (pos - down).distance > 4) {
      _isDragSelecting = true;
      final anchor = _hitTest(down);
      if (anchor != null) {
        ref
            .read(verseSelectionProvider.notifier)
            .startSelection(anchor.$1, anchor.$2);
      }
      setState(() {}); // switches to NeverScrollableScrollPhysics
    }
    if (_isDragSelecting) {
      final hit = _hitTest(pos);
      if (hit != null) {
        ref.read(verseSelectionProvider.notifier).updateFocus(hit.$1, hit.$2);
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.kind == PointerDeviceKind.mouse) {
      _isMouseDown = false;
      if (_isDragSelecting) {
        final selection = ref.read(verseSelectionProvider);
        if (selection.isSelecting) _showHighlightColorPicker(selection);
        _isDragSelecting = false;
        if (mounted) setState(() {});
      }
      _pointerDownPos = null;
      return;
    }
    // Quick tap (no long-press recognized): tear down the circle.
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
    if (_isDragSelecting) return; // mouse drag already started
    _longPressRecognized = true;
    // Schedule the action for the next frame. If a drag update arrives
    // on the same frame, _isDragSelecting will be true and we bail out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDragSelecting) return;
      _removeLoadingCircle();
      final hit = _hitTest(details.globalPosition);
      if (hit != null) {
        final highlightNote = _highlightNoteForWord(hit.$1, hit.$2);
        if (highlightNote != null) {
          // Long-press on an existing highlight → note-only popup.
          _showNotePopup(highlightNote, details.globalPosition);
        } else {
          final verse = _versesByNumber[hit.$1];
          if (verse != null) _showVerseActions(context, verse);
        }
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

  void _onTapHighlight(BuildContext context, ScriptureVerse verse, StudyNote note) {
    ref.read(verseSelectionProvider.notifier).setActiveHighlight(note);
    // Show handles after a frame so word keys are rendered at correct positions.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateHandleOverlays(note);
    });
    _showVerseActions(context, verse);
  }

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
          _notesByVerse = <int, List<StudyNote>>{};
          for (final note in notes) {
            final end = note.endVerseNumber ?? note.verseNumber;
            for (var v = note.verseNumber; v <= end; v++) {
              _notesByVerse.putIfAbsent(v, () => []).add(note);
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
                  child: MouseRegion(
                    cursor: SystemMouseCursors.text,
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
                              _notesByVerse[verse.number] ?? [];
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
                              onTapHighlight: (note) =>
                                  _onTapHighlight(context, verse, note),
                            ),
                          );
                        },
                      ),
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

// ── Highlight resize handle ───────────────────────────────────────────────

class _HighlightHandle extends StatefulWidget {
  final GlobalKey wordKey;
  final bool isStart;
  final VoidCallback onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;

  const _HighlightHandle({
    required this.wordKey,
    required this.isStart,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<_HighlightHandle> createState() => _HighlightHandleState();
}

class _HighlightHandleState extends State<_HighlightHandle> {
  Offset _position = Offset.zero;
  bool _positioned = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recalcPosition();
  }

  void _recalcPosition() {
    final ctx = widget.wordKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final global = box.localToGlobal(Offset.zero);
    // Start handle anchors to bottom-left of first word.
    // End handle anchors to bottom-right of last word.
    final newPos = widget.isStart
        ? Offset(global.dx - 6, global.dy + box.size.height - 6)
        : Offset(global.dx + box.size.width - 6, global.dy + box.size.height - 6);
    if (mounted) {
      setState(() {
        _position = newPos;
        _positioned = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_positioned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _recalcPosition();
      });
      return const SizedBox.shrink();
    }
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Listener(
        onPointerDown: (_) => widget.onDragStart(),
        onPointerMove: (e) => widget.onDragUpdate(e.position),
        onPointerUp: (_) => widget.onDragEnd(),
        onPointerCancel: (_) => widget.onDragEnd(),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(blurRadius: 2, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Note-only edit popup ──────────────────────────────────────────────────

class _NoteEditPopup extends StatefulWidget {
  final StudyNote note;
  final Offset anchorGlobal;
  final Future<void> Function(String text) onSave;
  final VoidCallback onDismiss;

  const _NoteEditPopup({
    required this.note,
    required this.anchorGlobal,
    required this.onSave,
    required this.onDismiss,
  });

  @override
  State<_NoteEditPopup> createState() => _NoteEditPopupState();
}

class _NoteEditPopupState extends State<_NoteEditPopup> {
  late final TextEditingController _textCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.note.content ?? '');
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(_textCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenSize = mq.size;
    final keyboardBottom = mq.viewInsets.bottom;

    const cardWidth = 280.0;
    const cardHeight = 200.0; // approximate
    const margin = 16.0;

    // Position card above the anchor; flip below if too close to top.
    double top = widget.anchorGlobal.dy - cardHeight - 12;
    if (top < margin) top = widget.anchorGlobal.dy + 24;
    // Clamp vertically above keyboard.
    final maxTop = screenSize.height - keyboardBottom - cardHeight - margin;
    top = top.clamp(margin, math.max(margin, maxTop));

    // Center horizontally on anchor, clamped to screen edges.
    double left = widget.anchorGlobal.dx - cardWidth / 2;
    left = left.clamp(margin, screenSize.width - cardWidth - margin);

    return Stack(
      children: [
        // Full-screen dismiss layer.
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        // Floating card.
        Positioned(
          left: left,
          top: top,
          width: cardWidth,
          child: GestureDetector(
            onTap: () {}, // absorb taps so they don't reach the dismiss layer
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text('Note',
                            style: Theme.of(context).textTheme.labelLarge),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: widget.onDismiss,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textCtrl,
                      maxLines: 4,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Add a note…',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
