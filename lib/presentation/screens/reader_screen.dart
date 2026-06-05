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

  /// Compact, bottom-pinned action bar shown while a highlight is active.
  /// Covers only a thin strip so the scripture above stays scrollable.
  OverlayEntry? _actionBarOverlay;

  // Links shared with each VerseWidget; the handle followers stay glued to the
  // active highlight's start/end anchor words via these.
  final LayerLink _startLink = LayerLink();
  final LayerLink _endLink = LayerLink();

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
    // Handles are CompositedTransformFollowers glued to their anchor words, so
    // they track scrolling on their own — no manual repositioning needed here.
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

  /// Inserts the two resize-handle followers for the active highlight. The
  /// handles are [CompositedTransformFollower]s glued to the start/end anchor
  /// words (see [VerseWidget]); they track the words frame-perfectly as the
  /// list scrolls and hide themselves when an anchor scrolls off-screen, so
  /// nothing needs repositioning on scroll.
  void _showHandleOverlays() {
    _removeHandleOverlaysOnly();
    if (ref.read(verseSelectionProvider).activeHighlight == null) return;

    final overlay = Overlay.of(context);
    _startHandleOverlay = OverlayEntry(
      builder: (_) => _HighlightHandle(
        link: _startLink,
        isStart: true,
        onDragStart: _beginHandleDrag,
        onDragUpdate: (pos) => _onHandleDragUpdate(pos, isStart: true),
        onDragEnd: _onHandleDragEnd,
      ),
    );
    _endHandleOverlay = OverlayEntry(
      builder: (_) => _HighlightHandle(
        link: _endLink,
        isStart: false,
        onDragStart: _beginHandleDrag,
        onDragUpdate: (pos) => _onHandleDragUpdate(pos, isStart: false),
        onDragEnd: _onHandleDragEnd,
      ),
    );
    overlay.insert(_startHandleOverlay!);
    overlay.insert(_endHandleOverlay!);
  }

  void _beginHandleDrag() {
    final active = ref.read(verseSelectionProvider).activeHighlight;
    if (active != null) {
      ref.read(verseSelectionProvider.notifier).beginHandleDrag(active);
    }
  }

  /// Removes just the handle followers, leaving the active-highlight bottom
  /// sheet in place.
  void _removeHandleOverlaysOnly() {
    _startHandleOverlay?.remove();
    _startHandleOverlay = null;
    _endHandleOverlay?.remove();
    _endHandleOverlay = null;
  }

  void _removeHandleOverlays() {
    _removeHandleOverlaysOnly();
    _actionBarOverlay?.remove();
    _actionBarOverlay = null;
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

    // Updating the live drag position relocates the anchor word's
    // CompositedTransformTarget, which the follower tracks automatically.
    ref
        .read(verseSelectionProvider.notifier)
        .updateHandleDrag(hit.$1, hit.$2, isStartHandle: isStart);
  }

  Future<void> _onHandleDragEnd() async {
    final s = ref.read(verseSelectionProvider);
    final note = s.activeHighlight;
    if (note == null) return;

    final newStartVerse = s.liveStartVerse ?? note.verseNumber;
    final newEndVerse = s.liveEndVerse ?? note.endVerseNumber ?? note.verseNumber;
    final isSingleVerse = newStartVerse == newEndVerse;
    final updated = note.copyWith(
      verseNumber: newStartVerse,
      startWordIndex: s.liveStartWord,
      clearStartWordIndex: s.liveStartWord == null,
      endWordIndex: s.liveEndWord,
      clearEndWordIndex: s.liveEndWord == null,
      endVerseNumber: isSingleVerse ? null : newEndVerse,
      clearEndVerseNumber: isSingleVerse,
    );

    await ref.read(noteRepositoryProvider).update(updated);
    ref.invalidate(chapterNotesProvider);
    ref.read(verseSelectionProvider.notifier).endHandleDrag();
    ref.read(verseSelectionProvider.notifier).setActiveHighlight(updated);
    // Followers re-glue to the relocated anchors automatically once the new
    // span is active; ensure the overlays are present (idempotent).
    _showHandleOverlays();
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

  /// Touch and stylus use the press-and-hold flow (with the progress circle)
  /// so a quick drag still scrolls the chapter. Mouse, trackpad, and any other
  /// precise pointer select directly on drag — no hold required. A laptop
  /// trackpad reports [PointerDeviceKind.trackpad], not `mouse`, so gating only
  /// on `mouse` would (wrongly) send it down the touch path.
  static bool _isTouchPointer(PointerDeviceKind kind) =>
      kind == PointerDeviceKind.touch ||
      kind == PointerDeviceKind.stylus ||
      kind == PointerDeviceKind.invertedStylus;

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

    if (!_isTouchPointer(event.kind)) {
      _isMouseDown = true;
      // No loading circle for mouse/trackpad — they drag-select directly.
    } else {
      _showLoadingCircle(event.position);
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isTouchPointer(event.kind) && _isMouseDown) {
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
      // Note: no setState here. Flutter's default scroll behavior on
      // web/desktop excludes mouse from dragDevices, so the ListView won't
      // scroll under us. Rebuilding the parent here would tear down the
      // pointer route mid-drag and freeze the selection at one word.
    }
    if (_isDragSelecting) {
      final hit = _hitTest(pos);
      if (hit != null) {
        ref.read(verseSelectionProvider.notifier).updateFocus(hit.$1, hit.$2);
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_isTouchPointer(event.kind)) {
      _isMouseDown = false;
      if (_isDragSelecting) {
        final selection = ref.read(verseSelectionProvider);
        if (selection.isSelecting) _commitSelectionHighlight(selection);
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
    // Synthetic cancels default to kind=touch, so gate on _isMouseDown
    // (set from the real PointerDown) rather than event.kind.
    if (_isMouseDown) return;
    if (!_longPressRecognized) {
      _removeLoadingCircle();
      _pointerDownPos = null;
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (_isMouseDown) return; // mouse Listener owns the gesture
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
    if (_isMouseDown) return; // mouse Listener owns the gesture
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
    if (_isMouseDown) return; // mouse Listener owns the gesture
    _removeLoadingCircle();
    if (_isDragSelecting) {
      final selection = ref.read(verseSelectionProvider);
      if (selection.isSelecting) {
        _commitSelectionHighlight(selection);
      }
    }
    _isDragSelecting = false;
    _longPressRecognized = false;
    _pointerDownPos = null;
    if (mounted) setState(() {});
  }

  void _onLongPressCancel() {
    // For mouse, the Listener drives selection — the long-press recognizer
    // fires onLongPressCancel as soon as the cursor moves past its slop,
    // which would clobber the in-progress mouse-drag selection. Bail out.
    if (_isMouseDown) return;
    _removeLoadingCircle();
    _isDragSelecting = false;
    _longPressRecognized = false;
    _pointerDownPos = null;
    ref.read(verseSelectionProvider.notifier).clearSelection();
    if (mounted) setState(() {});
  }

  // ── Action sheet & color picker ──────────────────────────────────────────

  void _onTapHighlight(StudyNote note) {
    ref.read(verseSelectionProvider.notifier).setActiveHighlight(note);
    // The handle followers glue to the anchor words via LayerLink, so they can
    // be inserted synchronously — no post-frame wait for word layout, which
    // also removes the old tap-away race that left phantom handles behind.
    _showHandleOverlays();
    _showHighlightActionBar(note);
  }

  /// Global rect of the active highlight's start (first) anchor word — the
  /// point the floating action bar hovers above. Falls back to the verse box
  /// when word keys aren't laid out yet.
  Rect? _activeHighlightAnchorRect() {
    final note = ref.read(verseSelectionProvider).activeHighlight;
    if (note == null) return null;
    final keys = _wordKeys[note.verseNumber];
    final wordIdx = note.startWordIndex ?? 0;
    final ctx = (keys != null && wordIdx < keys.length)
        ? keys[wordIdx].currentContext
        : _verseKeys[note.verseNumber]?.currentContext;
    final box = ctx?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Top/bottom Y of the scrolling reading window (the [ListView] viewport),
  /// in global coords. Used to pin the action bar to the top when the highlight
  /// scrolls off-screen above.
  (double, double)? _readingWindowBounds() {
    final box = _listKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    final top = box.localToGlobal(Offset.zero).dy;
    return (top, top + box.size.height);
  }

  /// Shows the compact, floating action bar that hovers just above the active
  /// highlight. It tracks scrolling and sticks to the top of the reading
  /// window when the highlight scrolls off-screen above (see
  /// [_HighlightActionBar]). Dismissed by tap-away (via [_onPointerDown]) or by
  /// [_removeHandleOverlays].
  void _showHighlightActionBar(StudyNote note) {
    _actionBarOverlay?.remove();
    _actionBarOverlay = OverlayEntry(
      builder: (_) => _HighlightActionBar(
        initialColor: note.highlightColorValue != null
            ? Color(note.highlightColorValue!)
            : HighlightColors.yellow,
        scrollController: _scrollController,
        resolveAnchorRect: _activeHighlightAnchorRect,
        resolveWindowBounds: _readingWindowBounds,
        onRecolor: _recolorActiveHighlight,
        onNote: _editActiveHighlightNote,
        onDelete: _deleteActiveHighlight,
      ),
    );
    Overlay.of(context).insert(_actionBarOverlay!);
  }

  Future<void> _recolorActiveHighlight(Color color) async {
    final note = ref.read(verseSelectionProvider).activeHighlight;
    if (note == null) return;
    final updated = note.copyWith(highlightColorValue: color.toARGB32());
    await ref.read(noteRepositoryProvider).update(updated);
    ref.invalidate(chapterNotesProvider);
    ref.read(verseSelectionProvider.notifier).setActiveHighlight(updated);
  }

  void _editActiveHighlightNote() {
    final note = ref.read(verseSelectionProvider).activeHighlight;
    if (note == null) return;
    // Anchor the popup to the highlight itself; _NoteEditPopup flips below and
    // clamps when there isn't room above.
    final rect = _activeHighlightAnchorRect();
    final size = MediaQuery.of(context).size;
    _showNotePopup(note, rect?.topCenter ?? Offset(size.width / 2, size.height / 2));
  }

  Future<void> _deleteActiveHighlight() async {
    final note = ref.read(verseSelectionProvider).activeHighlight;
    if (note == null) return;
    await ref.read(noteRepositoryProvider).delete(note.id);
    ref.invalidate(chapterNotesProvider);
    ref.read(verseSelectionProvider.notifier).clearActiveHighlight();
    _removeHandleOverlays();
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

  /// Commits a fresh drag-selection as a highlight with the default color, then
  /// surfaces the floating action bar above it (recolor / note / delete). The
  /// selection is cleared and the new note becomes the active highlight, so the
  /// flow mirrors tapping an existing highlight.
  Future<void> _commitSelectionHighlight(VerseSelectionState selection) async {
    final startVerse = selection.startVerse;
    final endVerse = selection.endVerse;
    if (startVerse == null || endVerse == null) return;

    final created = await ref.read(noteRepositoryProvider).create(StudyNote(
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
      highlightColorValue: HighlightColors.yellow.toARGB32(),
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    ref.read(verseSelectionProvider.notifier).clearSelection();
    ref.invalidate(chapterNotesProvider);
    _onTapHighlight(created); // sets active + shows handles + floating bar
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
                              startLink: _startLink,
                              endLink: _endLink,
                              onTapHighlight: _onTapHighlight,
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

class _HighlightHandle extends StatelessWidget {
  /// Link to the anchor word's [CompositedTransformTarget] in [VerseWidget].
  final LayerLink link;
  final bool isStart;
  final VoidCallback onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;

  const _HighlightHandle({
    required this.link,
    required this.isStart,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  // Visible dot vs. (larger) transparent grab area.
  static const double _dotSize = 12;
  static const double _hitSize = 28;

  @override
  Widget build(BuildContext context) {
    // Glue the handle's centre to the bottom-left (start) / bottom-right (end)
    // corner of the anchor word. The follower tracks the target every frame —
    // through scrolling and resize — and hides itself when the target isn't
    // currently painted (anchor scrolled off-screen) thanks to
    // showWhenUnlinked: false.
    //
    // The Positioned(left/top: 0) wrapper is REQUIRED: as a direct overlay
    // child, a bare follower would be laid out with tight full-screen
    // constraints, stretching the opaque Listener across the whole screen and
    // swallowing every tap (verses, app bar, back button). Positioning it gives
    // the follower loose constraints so it shrinks to the dot's hit area, while
    // the follower's own transform still places it over the anchor word.
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        targetAnchor: isStart ? Alignment.bottomLeft : Alignment.bottomRight,
        followerAnchor: Alignment.center,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => onDragStart(),
          onPointerMove: (e) => onDragUpdate(e.position),
          onPointerUp: (_) => onDragEnd(),
          onPointerCancel: (_) => onDragEnd(),
          child: SizedBox(
            width: _hitSize,
            height: _hitSize,
            child: Center(
              child: Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(blurRadius: 2, color: Colors.black26),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Active-highlight action bar ───────────────────────────────────────────

/// Top Y for the floating action bar. Floats [gap] above [anchorTop]; once the
/// anchor scrolls high enough that the bar would cross `windowTop + margin`, it
/// sticks there; it never leaves the reading window. Pure and frame-driven, so
/// the bar glides smoothly as [anchorTop] changes with scroll — no animation
/// controller needed. Public for unit testing.
double highlightActionBarTop({
  required double anchorTop,
  required double windowTop,
  required double windowBottom,
  required double barHeight,
  required double gap,
  required double margin,
}) {
  final desired = anchorTop - gap - barHeight; // float above the highlight
  final stuckToTop = windowTop + margin; // pinned-to-top floor
  final maxTop = windowBottom - barHeight - margin; // keep inside the window
  final floored = math.max(desired, stuckToTop);
  return floored.clamp(stuckToTop, math.max(stuckToTop, maxTop));
}

/// Compact, rounded action bar that floats just above the active highlight. It
/// tracks the highlight as the list scrolls and sticks to the top of the
/// reading window when the highlight scrolls off-screen above. Two faces share
/// one fixed footprint: the main face (current-color swatch · note · delete)
/// and the palette face (the full swatch row), swapped when the swatch is
/// tapped. Picking a color recolors and collapses back to the main face.
class _HighlightActionBar extends ConsumerStatefulWidget {
  final Color initialColor;
  final ScrollController scrollController;
  final Rect? Function() resolveAnchorRect;
  final (double, double)? Function() resolveWindowBounds;
  final ValueChanged<Color> onRecolor;
  final VoidCallback onNote;
  final VoidCallback onDelete;

  const _HighlightActionBar({
    required this.initialColor,
    required this.scrollController,
    required this.resolveAnchorRect,
    required this.resolveWindowBounds,
    required this.onRecolor,
    required this.onNote,
    required this.onDelete,
  });

  @override
  ConsumerState<_HighlightActionBar> createState() =>
      _HighlightActionBarState();
}

class _HighlightActionBarState extends ConsumerState<_HighlightActionBar> {
  late Color _current = widget.initialColor;
  bool _expanded = false;

  static const _barWidth = 244.0;
  static const _barHeight = 52.0;
  static const _gap = 10.0;
  static const _topMargin = 8.0;
  static const _edgeMargin = 12.0;
  static const _anim = Duration(milliseconds: 180);

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  // Recompute the bar position every scroll frame so it glides smoothly.
  void _onScroll() {
    if (mounted) setState(() {});
  }

  void _pick(Color color) {
    setState(() {
      _current = color;
      _expanded = false;
    });
    widget.onRecolor(color);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the active highlight / live handle-drag positions change so
    // the bar follows handle resizes as well as scrolling.
    ref.watch(verseSelectionProvider);

    final anchor = widget.resolveAnchorRect();
    final bounds = widget.resolveWindowBounds();
    if (anchor == null || bounds == null) return const SizedBox.shrink();

    final top = highlightActionBarTop(
      anchorTop: anchor.top,
      windowTop: bounds.$1,
      windowBottom: bounds.$2,
      barHeight: _barHeight,
      gap: _gap,
      margin: _topMargin,
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final left = (anchor.center.dx - _barWidth / 2).clamp(
      _edgeMargin,
      math.max(_edgeMargin, screenWidth - _barWidth - _edgeMargin),
    ).toDouble();

    final theme = Theme.of(context);
    return Positioned(
      left: left,
      top: top,
      child: Material(
        elevation: 8,
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: _barWidth,
          height: _barHeight,
          child: AnimatedSwitcher(
            duration: _anim,
            child: _expanded ? _paletteFace(theme) : _mainFace(theme),
          ),
        ),
      ),
    );
  }

  Widget _mainFace(ThemeData theme) {
    return Padding(
      key: const ValueKey('main'),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Current-color swatch — tap to reveal the palette face.
          _Swatch(
            color: _current,
            size: 30,
            selected: false,
            onTap: () => setState(() => _expanded = true),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.sticky_note_2_outlined),
            tooltip: 'Note',
            onPressed: widget.onNote,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete highlight',
            color: theme.colorScheme.error,
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }

  Widget _paletteFace(ThemeData theme) {
    return Padding(
      key: const ValueKey('palette'),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final color in HighlightColors.all)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _Swatch(
                color: color,
                size: 32,
                selected: color.toARGB32() == _current.toARGB32(),
                onTap: () => _pick(color),
              ),
            ),
        ],
      ),
    );
  }
}

/// A circular color swatch with an optional selection ring.
class _Swatch extends StatelessWidget {
  final Color color;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({
    required this.color,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2.5 : 1,
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
