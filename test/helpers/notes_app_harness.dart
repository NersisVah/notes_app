import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notes_app/domain/model/note_model.dart';
import 'package:notes_app/presentation/app.dart';
import 'package:notes_app/presentation/global_blocs/notes/notes_bloc.dart';
import 'package:notes_app/presentation/utils/router/app_router.dart';
import 'package:notes_app/presentation/utils/router/app_routes.dart';

import 'memory_storage.dart';

/// Starts the real app on Home with [notes] already saved, on a screen of
/// [size] with the system text scaled by [textScale]. Returns the storage so
/// tests can check what HydratedBloc saved.
Future<MemoryStorage> pumpNotesApp(
  WidgetTester tester, {
  List<NoteModel> notes = const [],
  Size size = const Size(400, 800),
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final storage = MemoryStorage();
  if (notes.isNotEmpty) {
    storage.values['NotesBloc'] = NotesState(notes: notes).toJson();
  }
  HydratedBloc.storage = storage;

  await tester.pumpWidget(const NoteApp());
  // The router is a single static instance, so it keeps the location of the
  // previous test.
  AppRouter.router.go(AppRoutes.home);
  await tester.pumpAndSettle();
  return storage;
}

/// The current [NotesBloc] state. NoteApp provides the bloc above
/// MaterialApp, so it's read from there.
NotesState notesState(WidgetTester tester) =>
    tester.element(find.byType(MaterialApp)).read<NotesBloc>().state;

/// The notes HydratedBloc wrote to [storage], i.e. what the next launch loads.
List<NoteModel> savedNotes(MemoryStorage storage) {
  final json = storage.values['NotesBloc'] as Map?;
  if (json == null) return const [];
  return NotesState.fromJson(Map<String, dynamic>.from(json)).notes;
}
