import 'package:flutter/rendering.dart';

/// Screen widths and system text scales every golden test renders.
const goldenWidths = [360.0, 768.0];
const goldenTextScales = [1.0, 2.0, 3.0];
const goldenHeight = 800.0;

/// File name for one width and text scale, for example `w360_x1.0.png`.
String goldenFileName(double width, double textScale) =>
    'w${width.toInt()}_x$textScale.png';

/// Runs [body] with real soft shadows. Flutter tests otherwise draw every
/// shadow as a solid black outline, which doesn't look like the app. The flag
/// must be back to its default before the test ends.
Future<void> withRealShadows(Future<void> Function() body) async {
  debugDisableShadows = false;
  try {
    await body();
  } finally {
    debugDisableShadows = true;
  }
}
