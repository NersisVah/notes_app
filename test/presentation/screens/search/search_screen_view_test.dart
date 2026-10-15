import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notes_app/presentation/app.dart';
import 'package:notes_app/presentation/global_blocs/notes/notes_bloc.dart';
import 'package:notes_app/presentation/screens/home/view/home_screen_view.dart';
import 'package:notes_app/presentation/screens/note_details/view/note_details_screen_view.dart';
import 'package:notes_app/presentation/screens/note_editor/view/note_editor_screen_view.dart';
import 'package:notes_app/presentation/screens/search/view/search_screen_view.dart';
import 'package:notes_app/presentation/utils/router/app_router.dart';
import 'package:notes_app/presentation/utils/router/app_routes.dart';

import '../../../helpers/memory_storage.dart';

void main() {
  setUp(() => HydratedBloc.storage = MemoryStorage());

  Future<NotesBloc> openSearchWithNotes(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpWidget(const NoteApp());
    // The router is a single static instance, so it keeps the location of
    // the previous test.
    AppRouter.router.go(AppRoutes.home);
    await tester.pumpAndSettle();
    final bloc = tester.element(find.byType(HomeScreenView)).read<NotesBloc>()
      ..add(const NoteAdded(title: 'Groceries', body: 'milk'))
      ..add(const NoteAdded(title: 'Work', body: 'meeting'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    return bloc;
  }

  testWidgets('shows all notes for an empty query and filters while typing', (
    tester,
  ) async {
    await openSearchWithNotes(tester);
    expect(find.byType(SearchScreenView), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);

    await tester.enterText(find.byType(TextField), 'MILK');
    await tester.pump();
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Work'), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('clear button empties the field and shows all notes', (
    tester,
  ) async {
    await openSearchWithNotes(tester);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No notes match your search'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.byIcon(Icons.close), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('editing a note opened from Search returns to Search', (
    tester,
  ) async {
    final bloc = await openSearchWithNotes(tester);
    await tester.enterText(find.byType(TextField), 'work');
    await tester.pump();

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteDetailsScreenView), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(NoteEditorScreenView), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).last, 'meeting moved');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back on the details screen with the new text, then back to Search.
    expect(find.byType(NoteDetailsScreenView), findsOneWidget);
    expect(find.text('meeting moved'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.byType(SearchScreenView), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
    expect(
      bloc.state.notes.firstWhere((note) => note.title == 'Work').body,
      'meeting moved',
    );
  });

  testWidgets('back button returns to Home', (tester) async {
    await openSearchWithNotes(tester);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreenView), findsOneWidget);
  });
}
