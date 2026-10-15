import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notes_app/presentation/app.dart';

import '../../helpers/notes_app_harness.dart';

/// Adds, updates, deletes, favorites and unfavorites notes across Home,
/// details, the editor and Search, and checks after every step that
/// NotesBloc, the screen and the saved storage agree.
void main() {
  Future<void> createNote(
    WidgetTester tester,
    String title,
    String body,
  ) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, title);
    await tester.enterText(find.byType(TextFormField).last, body);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.save_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // Lets the clock move so later notes get later dates.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
  }

  Future<void> back(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
  }

  testWidgets('every change reaches the bloc, the screen and storage', (
    tester,
  ) async {
    final storage = await pumpNotesApp(tester);
    List<String> titles() =>
        notesState(tester).notes.map((note) => note.title).toList()..sort();
    List<String> savedTitles() =>
        savedNotes(storage).map((note) => note.title).toList()..sort();

    // Add two notes.
    await createNote(tester, 'Groceries', 'milk');
    await createNote(tester, 'Work', 'meeting');
    expect(titles(), ['Groceries', 'Work']);
    expect(savedTitles(), ['Groceries', 'Work']);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);

    // Update Groceries from its details screen.
    final before = notesState(
      tester,
    ).notes.singleWhere((note) => note.title == 'Groceries');
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Shopping');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.save_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final after = notesState(
      tester,
    ).notes.singleWhere((note) => note.id == before.id);
    expect(after.title, 'Shopping');
    expect(after.createdAt, before.createdAt);
    expect(after.updatedAt.isAfter(before.updatedAt), isTrue);
    expect(find.text('Shopping'), findsOneWidget);
    expect(savedTitles(), ['Shopping', 'Work']);

    // Favorite it on details, then check Home and the Favorites filter.
    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();
    await back(tester);
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Work'), findsNothing);
    expect(
      savedNotes(storage).singleWhere((n) => n.title == 'Shopping').isFavorite,
      isTrue,
    );

    // Unfavorite it with a swipe while Favorites is shown.
    await tester.drag(find.text('Shopping'), const Offset(100, 0));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(IconButton),
        matching: find.byIcon(Icons.star),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No favorite notes yet.'), findsOneWidget);
    expect(notesState(tester).notes.every((n) => !n.isFavorite), isTrue);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Delete Work from Search.
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'meet');
    await tester.pump();
    await tester.drag(find.text('Work'), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No notes match your search'), findsOneWidget);
    await back(tester);
    expect(titles(), ['Shopping']);
    expect(savedTitles(), ['Shopping']);
    expect(find.text('Work'), findsNothing);

    // Relaunch: a new app instance loads the saved notes.
    await tester.pumpWidget(const SizedBox());
    HydratedBloc.storage = storage;
    await tester.pumpWidget(const NoteApp(key: ValueKey('relaunch')));
    await tester.pumpAndSettle();
    expect(titles(), ['Shopping']);
    expect(find.text('Shopping'), findsOneWidget);
  });
}
