import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/presentation/screens/home/view/home_screen_view.dart';
import 'package:notes_app/presentation/screens/note_details/view/note_details_screen_view.dart';
import 'package:notes_app/presentation/screens/search/view/search_screen_view.dart';

import '../../../../../helpers/notes_app_harness.dart';
import '../../../../../helpers/test_notes.dart';

void main() {
  Future<void> openSearch(WidgetTester tester) async {
    await pumpNotesApp(
      tester,
      notes: [
        testNote(1, title: 'Groceries', body: 'milk'),
        testNote(2, title: 'Work', body: 'meeting'),
      ],
    );
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
  }

  testWidgets('an empty query shows every note and no clear button', (
    tester,
  ) async {
    await openSearch(tester);
    expect(find.byType(SearchScreenView), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('typing filters by title or body, ignoring case', (tester) async {
    await openSearch(tester);
    await tester.enterText(find.byType(TextField), 'MILK');
    await tester.pump();
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Work'), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('no match shows the message; clear brings everything back', (
    tester,
  ) async {
    await openSearch(tester);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No notes match your search'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('favoriting from the results updates the bloc and the card', (
    tester,
  ) async {
    await openSearch(tester);
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
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('deleting from the results updates the bloc and the list', (
    tester,
  ) async {
    await openSearch(tester);
    await tester.drag(find.text('Work'), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsNothing);
    expect(notesState(tester).notes.single.title, 'Groceries');
  });

  testWidgets('a result opens details and back returns to Search', (
    tester,
  ) async {
    await openSearch(tester);
    await tester.enterText(find.byType(TextField), 'work');
    await tester.pump();
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteDetailsScreenView), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreenView), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
  });

  testWidgets('back returns to Home', (tester) async {
    await openSearch(tester);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreenView), findsOneWidget);
  });
}
