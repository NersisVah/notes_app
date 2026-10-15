import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/presentation/screens/note_details/view/note_details_screen_view.dart';
import 'package:notes_app/presentation/screens/note_editor/view/note_editor_screen_view.dart';
import 'package:notes_app/presentation/screens/search/view/search_screen_view.dart';

import '../../../../../helpers/notes_app_harness.dart';
import '../../../../../helpers/test_notes.dart';

void main() {
  // Note 1 was created first but edited last, so the two sort orders differ.
  final notes = [
    testNote(1, title: 'Groceries', editedAfter: const Duration(days: 1)),
    testNote(2, title: 'Birthday ideas', isFavorite: true),
    testNote(3, title: 'Work'),
  ];

  double topOf(WidgetTester tester, String title) =>
      tester.getTopLeft(find.text(title)).dy;

  testWidgets('shows the empty message when there are no notes', (
    tester,
  ) async {
    await pumpNotesApp(tester);
    expect(find.text('Create your first note!'), findsOneWidget);
  });

  testWidgets('lists notes newest updated first', (tester) async {
    await pumpNotesApp(tester, notes: notes);
    expect(topOf(tester, 'Groceries'), lessThan(topOf(tester, 'Work')));
    expect(topOf(tester, 'Work'), lessThan(topOf(tester, 'Birthday ideas')));
  });

  testWidgets('Favorites shows only favorites, All shows everything', (
    tester,
  ) async {
    await pumpNotesApp(tester, notes: notes);
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Birthday ideas'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
    expect(find.text('Work'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('Favorites without favorites shows its empty message', (
    tester,
  ) async {
    await pumpNotesApp(tester, notes: [testNote(1)]);
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('No favorite notes yet.'), findsOneWidget);
  });

  testWidgets('sort sheet switches to date created; current option is inert', (
    tester,
  ) async {
    await pumpNotesApp(tester, notes: notes);
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);

    // The selected option does nothing and the sheet stays open.
    await tester.tap(find.text('Date updated'));
    await tester.pumpAndSettle();
    expect(find.text('Date created'), findsOneWidget);

    await tester.tap(find.text('Date created'));
    await tester.pumpAndSettle();
    expect(find.text('Date created'), findsNothing);
    expect(topOf(tester, 'Work'), lessThan(topOf(tester, 'Birthday ideas')));
    expect(
      topOf(tester, 'Birthday ideas'),
      lessThan(topOf(tester, 'Groceries')),
    );
  });

  testWidgets('info button opens the info sheet', (tester) async {
    await pumpNotesApp(tester);
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Notes'), findsOneWidget);
    expect(find.text('Find them fast'), findsOneWidget);
  });

  testWidgets('swiping a card and tapping the star favorites it', (
    tester,
  ) async {
    await pumpNotesApp(tester, notes: notes);
    await tester.drag(find.text('Work'), const Offset(100, 0));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(IconButton),
        matching: find.byIcon(Icons.star_border),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      notesState(tester).notes.singleWhere((n) => n.title == 'Work').isFavorite,
      isTrue,
    );
  });

  testWidgets('a full swipe asks first; Cancel keeps, Delete removes', (
    tester,
  ) async {
    await pumpNotesApp(tester, notes: notes);
    await tester.drag(find.text('Work'), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(find.text('Delete this note?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsOneWidget);

    await tester.drag(find.text('Work'), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsNothing);
    expect(notesState(tester).notes, hasLength(2));
  });

  testWidgets('a card opens details, + opens the editor, search opens Search', (
    tester,
  ) async {
    await pumpNotesApp(tester, notes: notes);
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteDetailsScreenView), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(NoteEditorScreenView), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreenView), findsOneWidget);
  });
}
