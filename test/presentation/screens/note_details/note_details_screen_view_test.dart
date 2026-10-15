import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notes_app/presentation/app.dart';
import 'package:notes_app/presentation/global_blocs/notes/notes_bloc.dart';
import 'package:notes_app/presentation/screens/home/view/home_screen_view.dart';
import 'package:notes_app/presentation/screens/note_details/view/note_details_screen_view.dart';
import 'package:notes_app/presentation/screens/note_editor/view/note_editor_screen_view.dart';
import 'package:notes_app/presentation/utils/router/app_router.dart';
import 'package:notes_app/presentation/utils/router/app_routes.dart';

import '../../../helpers/memory_storage.dart';

void main() {
  setUp(() => HydratedBloc.storage = MemoryStorage());

  Future<NotesBloc> openDetails(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpWidget(const NoteApp());
    // The router is a single static instance, so it keeps the location of
    // the previous test.
    AppRouter.router.go(AppRoutes.home);
    await tester.pumpAndSettle();
    final bloc = tester.element(find.byType(HomeScreenView)).read<NotesBloc>()
      ..add(const NoteAdded(title: 'Groceries', body: 'milk and eggs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    return bloc;
  }

  testWidgets('tapping a card opens the details screen with the note', (
    tester,
  ) async {
    await openDetails(tester);
    expect(find.byType(NoteDetailsScreenView), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('milk and eggs'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byIcon(Icons.save_outlined), findsNothing);
  });

  testWidgets('favorite button toggles the favorite', (tester) async {
    final bloc = await openDetails(tester);
    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pump();
    expect(bloc.state.notes.single.isFavorite, isTrue);
    expect(find.byIcon(Icons.star), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star));
    await tester.pump();
    expect(bloc.state.notes.single.isFavorite, isFalse);
  });

  testWidgets('edit opens the editor in edit mode and saving returns here', (
    tester,
  ) async {
    await openDetails(tester);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(NoteEditorScreenView), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).first, 'Shopping');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteDetailsScreenView), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);
  });

  testWidgets('delete asks first, then removes the note and goes back', (
    tester,
  ) async {
    final bloc = await openDetails(tester);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteDetailsScreenView), findsOneWidget);
    expect(bloc.state.notes, hasLength(1));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreenView), findsOneWidget);
    expect(bloc.state.notes, isEmpty);
  });
}
