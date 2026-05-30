import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class VerseSelectionState {
  final bool isSelecting;
  final int? anchorVerse;
  final int? anchorWord;
  final int? focusVerse;
  final int? focusWord;

  const VerseSelectionState({
    this.isSelecting = false,
    this.anchorVerse,
    this.anchorWord,
    this.focusVerse,
    this.focusWord,
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
    );
  }

  @override
  bool operator ==(Object other) =>
      other is VerseSelectionState &&
      other.isSelecting == isSelecting &&
      other.anchorVerse == anchorVerse &&
      other.anchorWord == anchorWord &&
      other.focusVerse == focusVerse &&
      other.focusWord == focusWord;

  @override
  int get hashCode => Object.hash(
        isSelecting,
        anchorVerse,
        anchorWord,
        focusVerse,
        focusWord,
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
}

final verseSelectionProvider =
    NotifierProvider<VerseSelectionController, VerseSelectionState>(
  VerseSelectionController.new,
);
