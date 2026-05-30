import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/study_project.dart';

@immutable
class VerseSelectionState {
  final bool isSelecting;
  final int? anchorVerse;
  final int? anchorWord;
  final int? focusVerse;
  final int? focusWord;

  /// The existing highlight currently "tapped" — drives border outline + handles.
  final StudyNote? activeHighlight;

  /// True while the user is dragging a resize handle on [activeHighlight].
  final bool isDraggingHandle;

  /// Live word/verse positions during a handle drag (null = use saved note values).
  final int? liveStartVerse;
  final int? liveStartWord;
  final int? liveEndVerse;
  final int? liveEndWord;

  const VerseSelectionState({
    this.isSelecting = false,
    this.anchorVerse,
    this.anchorWord,
    this.focusVerse,
    this.focusWord,
    this.activeHighlight,
    this.isDraggingHandle = false,
    this.liveStartVerse,
    this.liveStartWord,
    this.liveEndVerse,
    this.liveEndWord,
  });

  // Normalized so startVerse <= endVerse regardless of drag direction.
  int? get startVerse {
    if (anchorVerse == null || focusVerse == null) return anchorVerse;
    return anchorVerse! <= focusVerse! ? anchorVerse : focusVerse;
  }

  int? get endVerse {
    if (anchorVerse == null || focusVerse == null) return anchorVerse;
    return anchorVerse! >= focusVerse! ? anchorVerse : focusVerse;
  }

  int? get startWord {
    if (anchorVerse == null || focusVerse == null) return anchorWord;
    return anchorVerse! <= focusVerse! ? anchorWord : focusWord;
  }

  int? get endWord {
    if (anchorVerse == null || focusVerse == null) return anchorWord;
    return anchorVerse! >= focusVerse! ? anchorWord : focusWord;
  }

  /// Returns the selected word range `(startIdx, endIdx)` for [verseNumber],
  /// or null if this verse is not part of the current selection.
  (int, int)? rangeForVerse(int verseNumber, int wordCount) {
    if (!isSelecting || startVerse == null || endVerse == null) return null;
    if (verseNumber < startVerse! || verseNumber > endVerse!) return null;

    if (startVerse == endVerse) {
      return (startWord ?? 0, endWord ?? (wordCount - 1));
    }
    if (verseNumber == startVerse) return (startWord ?? 0, wordCount - 1);
    if (verseNumber == endVerse) return (0, endWord ?? (wordCount - 1));
    // Middle verse — fully selected.
    return (0, wordCount - 1);
  }

  VerseSelectionState copyWith({
    bool? isSelecting,
    int? anchorVerse,
    int? anchorWord,
    int? focusVerse,
    int? focusWord,
  }) {
    return VerseSelectionState(
      isSelecting: isSelecting ?? this.isSelecting,
      anchorVerse: anchorVerse ?? this.anchorVerse,
      anchorWord: anchorWord ?? this.anchorWord,
      focusVerse: focusVerse ?? this.focusVerse,
      focusWord: focusWord ?? this.focusWord,
      activeHighlight: activeHighlight,
      isDraggingHandle: isDraggingHandle,
      liveStartVerse: liveStartVerse,
      liveStartWord: liveStartWord,
      liveEndVerse: liveEndVerse,
      liveEndWord: liveEndWord,
    );
  }

  /// Returns a new state with updated live drag positions, clearing
  /// [isDraggingHandle] when called with no arguments.
  VerseSelectionState _withLive({
    int? startVerse,
    int? startWord,
    int? endVerse,
    int? endWord,
    bool dragging = false,
  }) {
    return VerseSelectionState(
      isSelecting: isSelecting,
      anchorVerse: anchorVerse,
      anchorWord: anchorWord,
      focusVerse: focusVerse,
      focusWord: focusWord,
      activeHighlight: activeHighlight,
      isDraggingHandle: dragging,
      liveStartVerse: startVerse,
      liveStartWord: startWord,
      liveEndVerse: endVerse,
      liveEndWord: endWord,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is VerseSelectionState &&
      other.isSelecting == isSelecting &&
      other.anchorVerse == anchorVerse &&
      other.anchorWord == anchorWord &&
      other.focusVerse == focusVerse &&
      other.focusWord == focusWord &&
      other.activeHighlight?.id == activeHighlight?.id &&
      other.isDraggingHandle == isDraggingHandle &&
      other.liveStartVerse == liveStartVerse &&
      other.liveStartWord == liveStartWord &&
      other.liveEndVerse == liveEndVerse &&
      other.liveEndWord == liveEndWord;

  @override
  int get hashCode => Object.hash(
        isSelecting,
        anchorVerse,
        anchorWord,
        focusVerse,
        focusWord,
        activeHighlight?.id,
        isDraggingHandle,
        liveStartVerse,
        liveStartWord,
        liveEndVerse,
        liveEndWord,
      );
}

class VerseSelectionController extends Notifier<VerseSelectionState> {
  @override
  VerseSelectionState build() => const VerseSelectionState();

  void startSelection(int verseNumber, int wordIndex) {
    state = VerseSelectionState(
      isSelecting: true,
      anchorVerse: verseNumber,
      anchorWord: wordIndex,
      focusVerse: verseNumber,
      focusWord: wordIndex,
    );
  }

  void updateFocus(int verseNumber, int wordIndex) {
    if (!state.isSelecting) return;
    state = state.copyWith(focusVerse: verseNumber, focusWord: wordIndex);
  }

  void clearSelection() {
    state = const VerseSelectionState();
  }

  /// Sets [note] as the tapped/active highlight (shows border + handles).
  void setActiveHighlight(StudyNote note) {
    state = VerseSelectionState(activeHighlight: note);
  }

  /// Clears the active highlight, border, and any handle drag state.
  void clearActiveHighlight() {
    state = const VerseSelectionState();
  }

  /// Begins a handle drag on [note], seeding live positions from saved values.
  void beginHandleDrag(StudyNote note) {
    final endVerse = note.endVerseNumber ?? note.verseNumber;
    state = VerseSelectionState(
      activeHighlight: note,
      isDraggingHandle: true,
      liveStartVerse: note.verseNumber,
      liveStartWord: note.startWordIndex ?? 0,
      liveEndVerse: endVerse,
      liveEndWord: note.endWordIndex,
    );
  }

  /// Updates the live start or end position during a handle drag.
  void updateHandleDrag(int verse, int word, {required bool isStartHandle}) {
    if (isStartHandle) {
      state = state._withLive(
        startVerse: verse,
        startWord: word,
        endVerse: state.liveEndVerse,
        endWord: state.liveEndWord,
        dragging: true,
      );
    } else {
      state = state._withLive(
        startVerse: state.liveStartVerse,
        startWord: state.liveStartWord,
        endVerse: verse,
        endWord: word,
        dragging: true,
      );
    }
  }

  /// Ends the handle drag, keeping [activeHighlight] but clearing live positions.
  void endHandleDrag() {
    state = state._withLive();
  }
}

final verseSelectionProvider =
    NotifierProvider<VerseSelectionController, VerseSelectionState>(
  VerseSelectionController.new,
);
