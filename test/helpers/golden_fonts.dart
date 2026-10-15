import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the real Roboto and Material Icons fonts from `test/fonts/`, so
/// golden images show readable text and icons instead of Flutter's default
/// test font, which draws every character as a square.
Future<void> loadGoldenFonts() async {
  await _load('Roboto', 'test/fonts/Roboto-Regular.ttf');
  await _load('MaterialIcons', 'test/fonts/MaterialIcons-Regular.otf');
}

Future<void> _load(String family, String path) async {
  final bytes = await File(path).readAsBytes();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}
