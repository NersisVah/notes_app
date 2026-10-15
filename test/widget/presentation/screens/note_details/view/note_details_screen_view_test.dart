import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/presentation/screens/home/view/home_screen_view.dart';
import 'package:notes_app/presentation/screens/note_details/view/note_details_screen_view.dart';
import 'package:notes_app/presentation/screens/note_editor/view/note_editor_screen_view.dart';

import '../../../../../helpers/notes_app_harness.dart';
import '../../../../../helpers/test_notes.dart';

void main() {
  Future<void> openDetails(
    WidgetTester tester, {
    bool isFavorite = false,
  }) async {
    await pumpNotesApp(
      tester,
      notes: [
        testNote(
          1,
          title: 'Groceries',
          body: 'milk and eggs',
          isFavorite: isFavorite,
          editedAfter: const Duration(hours: 2, minutes: 30),
        ),
      ],
    );
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the note, its dates and no editing controls', (
    tester,
  ) async {
    await openDetails(tester);
    expect(find.byType(NoteDetailsScreenView), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('milk and eggs'), findsOneWidget);
    // testNote(1) is created at 10:00 on 1 Jan 2026 and edited 2.5 h later.
    expect(find.text('Created at: 01.01.2026 10:00'), findsOneWidget);
    expect(find.text('Updated at: 01.01.2026 12:30'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byIcon(Icons.save_outlined), findsNothing);
  });

  testWidgets('the star favorites and unfavorites the note', (tester) async {
    await openDetails(tester);
    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pump();
    expect(notesState(tester).notes.single.isFavorite, isTrue);
    expect(find.byIcon(Icons.star), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star));
    await tester.pump();
    expect(notesState(tester).notes.single.isFavorite, isFalse);
  });

  testWidgets('a favorite shows the filled star', (tester) async {
    await openDetails(tester, isFavorite: true);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('the pencil opens the editor for this note', (tester) async {
    await openDetails(tester);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(NoteEditorScreenView), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Groceries'), findsOneWidget);
  });

  testWidgets('delete asks first; Delete removes the note and goes back', (
    tester,
  ) async {
    await openDetails(tester);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(notesState(tester).notes, hasLength(1));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreenView), findsOneWidget);
    expect(notesState(tester).notes, isEmpty);
  });
}
