import 'package:flutter_test/flutter_test.dart';
import 'package:scriptures_app/presentation/controllers/verse_selection_controller.dart';

/// These tests pin down the selection-range normalization that a regression
/// once broke: a same-verse drag collapsed to a single word because the
/// start/end-word getters compared VERSES instead of WORDS when the anchor
/// and focus shared a verse. See [VerseSelectionState] normalization getters.
void main() {
  VerseSelectionState sel({
    required int aV,
    required int aW,
    required int fV,
    required int fW,
  }) =>
      VerseSelectionState(
        isSelecting: true,
        anchorVerse: aV,
        anchorWord: aW,
        focusVerse: fV,
        focusWord: fW,
      );

  group('same-verse selection', () {
    test('forward drag widens the word range with focus', () {
      // Anchor word 27, drag right to word 29 within verse 3.
      final s = sel(aV: 3, aW: 27, fV: 3, fW: 29);
      expect(s.startVerse, 3);
      expect(s.endVerse, 3);
      expect(s.startWord, 27);
      expect(s.endWord, 29); // ← regression returned 27 here
      expect(s.rangeForVerse(3, 40), (27, 29));
    });

    test('backward drag is normalized to ascending order', () {
      // Anchor word 29, drag LEFT to word 27.
      final s = sel(aV: 3, aW: 29, fV: 3, fW: 27);
      expect(s.startWord, 27);
      expect(s.endWord, 29);
      expect(s.rangeForVerse(3, 40), (27, 29));
    });

    test('single word (anchor == focus) selects exactly that word', () {
      final s = sel(aV: 3, aW: 27, fV: 3, fW: 27);
      expect(s.rangeForVerse(3, 40), (27, 27));
    });
  });

  group('multi-verse selection', () {
    test('forward drag orders by composite (verse, word)', () {
      final s = sel(aV: 3, aW: 5, fV: 5, fW: 2);
      expect(s.startVerse, 3);
      expect(s.endVerse, 5);
      expect(s.startWord, 5);
      expect(s.endWord, 2);
    });

    test('backward drag (focus above anchor) is normalized', () {
      final s = sel(aV: 5, aW: 2, fV: 3, fW: 5);
      expect(s.startVerse, 3);
      expect(s.endVerse, 5);
      expect(s.startWord, 5);
      expect(s.endWord, 2);
    });

    test('rangeForVerse: first verse runs to its last word', () {
      final s = sel(aV: 3, aW: 5, fV: 5, fW: 2);
      expect(s.rangeForVerse(3, 10), (5, 9));
    });

    test('rangeForVerse: middle verse is fully selected', () {
      final s = sel(aV: 3, aW: 5, fV: 5, fW: 2);
      expect(s.rangeForVerse(4, 8), (0, 7));
    });

    test('rangeForVerse: last verse runs from its first word', () {
      final s = sel(aV: 3, aW: 5, fV: 5, fW: 2);
      expect(s.rangeForVerse(5, 10), (0, 2));
    });

    test('rangeForVerse: verse outside the span returns null', () {
      final s = sel(aV: 3, aW: 5, fV: 5, fW: 2);
      expect(s.rangeForVerse(6, 10), isNull);
    });
  });

  test('not selecting → rangeForVerse is null', () {
    const s = VerseSelectionState();
    expect(s.rangeForVerse(3, 40), isNull);
  });
}
