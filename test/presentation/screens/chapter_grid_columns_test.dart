import 'package:flutter_test/flutter_test.dart';
import 'package:scriptures_app/presentation/screens/chapters_screen.dart';

/// Pins down the chapter-picker grid's responsive column count
/// ([chapterGridColumns]): pills target ~half the "New Study" button width
/// (~80px), so phones land near four per row while tablets and desktop fit as
/// many as the width allows, and it never drops below one column.
void main() {
  group('chapterGridColumns', () {
    test('typical phone width yields four pills per row', () {
      expect(chapterGridColumns(360), 4);
    });

    test('narrow phone yields about three (acceptably close to four)', () {
      expect(chapterGridColumns(320), 3);
    });

    test('tablet width fits more columns', () {
      expect(chapterGridColumns(768), greaterThanOrEqualTo(8));
    });

    test('desktop width grows further still', () {
      expect(chapterGridColumns(1280), greaterThan(chapterGridColumns(768)));
    });

    test('degenerate tiny/zero width never returns fewer than one column', () {
      expect(chapterGridColumns(0), 1);
      expect(chapterGridColumns(10), 1);
    });

    test('column count is monotonic non-decreasing in width', () {
      var prev = 0;
      for (var w = 0.0; w <= 2000; w += 17) {
        final cols = chapterGridColumns(w);
        expect(cols, greaterThanOrEqualTo(prev));
        prev = cols;
      }
    });
  });
}
