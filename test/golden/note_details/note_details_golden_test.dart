@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/domain/model/note_model.dart';
import 'package:notes_app/presentation/app.dart';
import 'package:notes_app/presentation/utils/router/app_router.dart';
import 'package:notes_app/presentation/utils/router/app_routes.dart';

import '../../helpers/golden_fonts.dart';
import '../../helpers/golden_helpers.dart';
import '../../helpers/notes_app_harness.dart';
import '../../helpers/test_notes.dart';

/// The note details screen for every width × text scale × content state,
/// saved as `goldens/<state>/w<width>_x<scale>.png`.
void main() {
  setUpAll(loadGoldenFonts);

  for (final contentState in _DetailsState.values) {
    group(contentState.folder, () {
      for (final width in goldenWidths) {
        for (final scale in goldenTextScales) {
          testWidgets('width ${width.toInt()}, text x$scale', (tester) async {
            await withRealShadows(() async {
              await pumpNotesApp(
                tester,
                notes: [contentState.note],
                size: Size(width, goldenHeight),
                textScale: scale,
              );
              AppRouter.router.push(
                AppRoutes.noteDetailsById(contentState.note.id),
              );
              await tester.pumpAndSettle();
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

enum _DetailsState {
  /// A short note that isn't a favorite and was never edited.
  shortNote('short_note'),

  /// A favorite with a long title and a body longer than the screen, edited
  /// after it was created.
  longFavorite('long_favorite');

  const _DetailsState(this.folder);

  final String folder;

  NoteModel get note => switch (this) {
    shortNote => testNote(1, title: 'Groceries', body: 'Milk, eggs and bread.'),
    longFavorite => testNote(
      1,
      title: 'Ideas for the summer trip with friends and family',
      body: List.filled(
        12,
        'Book the train tickets early, pack light, and keep a list of the '
        'places everyone wants to see.',
      ).join('\n\n'),
      isFavorite: true,
      editedAfter: const Duration(days: 3, hours: 4, minutes: 15),
    ),
  };
}
