import 'package:flutter_test/flutter_test.dart';
import 'package:scriptures_app/presentation/screens/reader_screen.dart';

/// Pins down the floating highlight action bar's vertical placement rule
/// ([highlightActionBarTop]): it floats above the highlight, sticks to the top
/// of the reading window when the highlight scrolls off-screen above, glides
/// smoothly between the two, and never leaves the window. The widget itself is
/// frame-driven; this pure function is the part worth testing.
void main() {
  // A representative reading window + bar metrics.
  const windowTop = 80.0;
  const windowBottom = 800.0;
  const barHeight = 52.0;
  const gap = 10.0;
  const margin = 8.0;

  double topFor(double anchorTop) => highlightActionBarTop(
        anchorTop: anchorTop,
        windowTop: windowTop,
        windowBottom: windowBottom,
        barHeight: barHeight,
        gap: gap,
        margin: margin,
      );

  group('highlightActionBarTop', () {
    test('normal: floats exactly gap+barHeight above an in-view anchor', () {
      const anchorTop = 400.0;
      expect(topFor(anchorTop), anchorTop - gap - barHeight); // 338
    });

    test('stuck-to-top: anchor above the window pins the bar to windowTop+margin',
        () {
      // Anchor scrolled well above the viewport top.
      expect(topFor(20.0), windowTop + margin); // 88
      // Even far off-screen above, it stays pinned (does not keep rising).
      expect(topFor(-500.0), windowTop + margin);
    });

    test('glide continuity: decreasing anchorTop never raises the bar abruptly',
        () {
      double? prev;
      for (var anchorTop = 400.0; anchorTop >= -100.0; anchorTop -= 1.0) {
        final top = topFor(anchorTop);
        if (prev != null) {
          // Monotonically non-increasing, and each step moves at most 1px
          // (no sudden relocation) until it settles at the pinned floor.
          expect(top, lessThanOrEqualTo(prev));
          expect(prev - top, lessThanOrEqualTo(1.0 + 1e-9));
        }
        prev = top;
      }
      // Ends pinned at the top floor.
      expect(prev, windowTop + margin);
    });

    test('bottom clamp: anchor below the window keeps the bar inside it', () {
      const maxTop = windowBottom - barHeight - margin; // 740
      expect(topFor(900.0), maxTop);
      expect(topFor(5000.0), maxTop);
    });

    test('degenerate window (shorter than the bar) never returns below the floor',
        () {
      // windowBottom - barHeight - margin would be < windowTop + margin here.
      final top = highlightActionBarTop(
        anchorTop: 1000.0,
        windowTop: 100.0,
        windowBottom: 120.0,
        barHeight: barHeight,
        gap: gap,
        margin: margin,
      );
      expect(top, 100.0 + margin); // falls back to the stuck-to-top floor
    });
  });
}
