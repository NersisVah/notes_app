import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/presentation/screens/home/view/home_screen_view.dart';
import 'package:notes_app/presentation/screens/note_details/view/note_details_screen_view.dart';
import 'package:notes_app/presentation/screens/note_editor/view/note_editor_screen_view.dart';

import '../../../../../helpers/notes_app_harness.dart';
import '../../../../../helpers/test_notes.dart';

void main() {
  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byIcon(Icons.save_outlined),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed !=
      null;

  Future<void> openNewNote(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String title, String body) async {
    await tester.enterText(find.byType(TextFormField).first, title);
    await tester.enterText(find.byType(TextFormField).last, body);
    await tester.pumpAndSettle();
  }

  Future<void> saveAndConfirm(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.save_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  group('new note', () {
    testWidgets('opens empty with Save disabled', (tester) async {
      await pumpNotesApp(tester);
      await openNewNote(tester);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(saveEnabled(tester), isFalse);
    });

    testWidgets('Save stays disabled while a field is empty or spaces', (
      tester,
    ) async {
      await pumpNotesApp(tester);
      await openNewNote(tester);
      await type(tester, 'Title', '');
      expect(saveEnabled(tester), isFalse);
      await type(tester, '   ', 'Body');
      expect(saveEnabled(tester), isFalse);
      expect(find.text("Title can't be empty"), findsOneWidget);
      await type(tester, 'Title', 'Body');
      expect(saveEnabled(tester), isTrue);
    });

    testWidgets('saving adds the note and returns to Home', (tester) async {
      await pumpNotesApp(tester);
      await openNewNote(tester);
      await type(tester, 'Groceries', 'milk');
      await saveAndConfirm(tester);
      expect(find.byType(HomeScreenView), findsOneWidget);
      expect(notesState(tester).notes.single.title, 'Groceries');
    });

    testWidgets('cancelling the save dialog keeps editing and adds nothing', (
      tester,
    ) async {
      await pumpNotesApp(tester);
      await openNewNote(tester);
      await type(tester, 'Groceries', 'milk');
      await tester.tap(find.byIcon(Icons.save_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(NoteEditorScreenView), findsOneWidget);
      expect(notesState(tester).notes, isEmpty);
    });
  });

  group('back', () {
    testWidgets('without changes leaves right away', (tester) async {
      await pumpNotesApp(tester);
      await openNewNote(tester);
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreenView), findsOneWidget);
    });

    testWidgets('with changes asks; Stay keeps editing, Leave discards', (
      tester,
    ) async {
      await pumpNotesApp(tester);
      await openNewNote(tester);
      await type(tester, 'Draft', 'text');

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();
      expect(find.byType(NoteEditorScreenView), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreenView), findsOneWidget);
      expect(notesState(tester).notes, isEmpty);
    });
  });

  group('Android system back', () {
    testWidgets('without changes leaves right away', (tester) async {
      await pumpNotesApp(tester);
      await openNewNote(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreenView), findsOneWidget);
    });

    testWidgets('with changes asks before leaving', (tester) async {
      await pumpNotesApp(tester);
      await openNewNote(tester);
      await type(tester, 'Draft', 'text');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Leave'), findsOneWidget);
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreenView), findsOneWidget);
      expect(notesState(tester).notes, isEmpty);
    });
  });

  group('existing note', () {
    Future<void> openEditor(WidgetTester tester) async {
      await pumpNotesApp(
        tester,
        notes: [testNote(1, title: 'Groceries', body: 'milk')],
      );
      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
    }

    testWidgets('opens in edit mode with its text and Save disabled', (
      tester,
    ) async {
      await openEditor(tester);
      expect(find.widgetWithText(TextFormField, 'Groceries'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'milk'), findsOneWidget);
      expect(saveEnabled(tester), isFalse);
    });

    testWidgets('saving updates the note and returns to details', (
      tester,
    ) async {
      await openEditor(tester);
      await type(tester, 'Shopping', 'bread');
      await saveAndConfirm(tester);
      expect(find.byType(NoteDetailsScreenView), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      final note = notesState(tester).notes.single;
      expect(note.id, 'note-1');
      expect(note.title, 'Shopping');
      expect(note.body, 'bread');
    });
  });

  testWidgets('the eye button previews the text and the pencil returns', (
    tester,
  ) async {
    await pumpNotesApp(tester);
    await openNewNote(tester);
    await type(tester, 'Draft', 'preview me');
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('preview me'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'preview me'), findsOneWidget);
  });
}
