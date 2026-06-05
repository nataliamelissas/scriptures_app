import 'package:flutter_test/flutter_test.dart';
import 'package:scriptures_app/domain/entities/scripture.dart';
import 'package:scriptures_app/domain/entities/study_project.dart';

/// Pins down [StudyNote.copyWith]'s nullable-field handling. The default
/// `value ?? this.value` idiom can only SET a field; the `clear*` flags exist
/// so a resize can genuinely null out a field (e.g. shrinking a multi-verse
/// highlight back down to a single verse). See `_onHandleDragEnd` in
/// ReaderScreen, the original caller.
void main() {
  StudyNote note({
    int verseNumber = 5,
    String? content,
    int? endVerseNumber,
    int? startWordIndex,
    int? endWordIndex,
  }) =>
      StudyNote(
        id: 'n1',
        projectId: 'p1',
        volume: StandardWork.bookOfMormon,
        bookApiId: 'alma',
        chapter: 32,
        verseNumber: verseNumber,
        type: NoteType.highlight,
        content: content,
        highlightColorValue: 0xFF00FF00,
        endVerseNumber: endVerseNumber,
        startWordIndex: startWordIndex,
        endWordIndex: endWordIndex,
        createdAt: DateTime(2026, 1, 1),
      );

  group('StudyNote.copyWith', () {
    test('passing null without a clear flag retains the old value', () {
      final original = note(endVerseNumber: 7);
      // The `?? this` idiom means null is a no-op, not a clear.
      final copy = original.copyWith(endVerseNumber: null);
      expect(copy.endVerseNumber, 7);
    });

    test('clearEndVerseNumber nulls a multi-verse span (shrink to single verse)',
        () {
      final multi = note(verseNumber: 5, endVerseNumber: 7, endWordIndex: 4);
      // Drag the end handle back into the start verse: the span collapses.
      final shrunk = multi.copyWith(
        endVerseNumber: null,
        clearEndVerseNumber: true,
        endWordIndex: 2,
      );
      expect(shrunk.endVerseNumber, isNull);
      expect(shrunk.verseNumber, 5);
      expect(shrunk.endWordIndex, 2);
    });

    test('clearStartWordIndex/clearEndWordIndex reset to whole-verse (null)', () {
      final partial = note(startWordIndex: 2, endWordIndex: 4);
      final whole = partial.copyWith(
        clearStartWordIndex: true,
        clearEndWordIndex: true,
      );
      expect(whole.startWordIndex, isNull);
      expect(whole.endWordIndex, isNull);
    });

    test('clearContent nulls an existing note body (emptying the text field)',
        () {
      final annotated = note(content: 'faith is a seed');
      // Saving the note popup with an empty text field must remove the body,
      // not retain the prior content via the `?? this` idiom.
      final cleared = annotated.copyWith(clearContent: true);
      expect(cleared.content, isNull);
    });

    test('a clear flag takes precedence over a concurrently-passed value', () {
      final original = note(endVerseNumber: 7);
      final copy = original.copyWith(
        endVerseNumber: 9,
        clearEndVerseNumber: true,
      );
      expect(copy.endVerseNumber, isNull);
    });
  });
}
