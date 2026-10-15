@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/domain/model/note_model.dart';
import 'package:notes_app/presentation/app.dart';

import '../../helpers/golden_fonts.dart';
import '../../helpers/golden_helpers.dart';
import '../../helpers/notes_app_harness.dart';
import '../../helpers/test_notes.dart';

/// The Home notes list for every width × text scale × content state, saved as
/// `goldens/<state>/w<width>_x<scale>.png`.
void main() {
  setUpAll(loadGoldenFonts);

  for (final contentState in _HomeListState.values) {
    group(contentState.folder, () {
      for (final width in goldenWidths) {
        for (final scale in goldenTextScales) {
          testWidgets('width ${width.toInt()}, text x$scale', (tester) async {
            await withRealShadows(() async {
              await pumpNotesApp(
                tester,
                notes: contentState.notes,
                size: Size(width, goldenHeight),
                textScale: scale,
              );
              if (contentState == _HomeListState.favoritesEmpty) {
                await tester.tap(find.text('Favorites'));
                await tester.pumpAndSettle();
              }
              await expectLater(
                find.byType(NoteApp),
                matchesGoldenFile(
                  'goldens/${contentState.folder}/'
                  '${goldenFileName(width, scale)}',
                ),
              );
            });
          });
        }
      }
    });
  }
}

enum _HomeListState {
  /// No notes yet: "Create your first note!".
  empty('empty'),

  /// Favorites filter with no favorites: "No favorite notes yet.".
  favoritesEmpty('favorites_empty'),

  /// Three short notes, one of them a favorite.
  fewNotes('few_notes'),

  /// Twelve notes with long, wrapping titles and several favorites.
  longAndMany('long_and_many');

  const _HomeListState(this.folder);

  final String folder;

  List<NoteModel> get notes => switch (this) {
    empty => const [],
    favoritesEmpty => [
      testNote(1, title: 'Groceries'),
      testNote(2, title: 'Work'),
    ],
    fewNotes => [
      testNote(1, title: 'Groceries'),
      testNote(2, title: 'Birthday ideas', isFavorite: true),
      testNote(3, title: 'Work'),
    ],
    longAndMany => [
      for (var i = 1; i <= 12; i++)
        testNote(
          i,
          title: i.isEven
              ? 'Note $i with a long title that needs more than one line to fit'
              : 'Note $i',
          isFavorite: i % 3 == 0,
        ),
    ],
  };
}
