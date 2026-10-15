import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/presentation/screens/note_editor/view_model/note_editor_cubit.dart';

import '../../../../../helpers/bloc_states.dart';
import '../../../../../helpers/test_notes.dart';

void main() {
  group('initial state', () {
    test('a new note starts empty in edit mode with nothing to save', () {
      final state = NoteEditorCubit().state;
      expect(state.mode, NoteEditorMode.edit);
      expect(state.title, isEmpty);
      expect(state.body, isEmpty);
      expect(state.hasChanges, isFalse);
      expect(state.canSave, isFalse);
    });

    test('an existing note starts in edit mode with its text', () {
      final note = testNote(1, title: 'Groceries', body: 'milk');
      final state = NoteEditorCubit(note: note).state;
      expect(state.mode, NoteEditorMode.edit);
      expect(state.title, 'Groceries');
      expect(state.body, 'milk');
      expect(state.savedTitle, 'Groceries');
      expect(state.savedBody, 'milk');
      expect(state.hasChanges, isFalse);
      expect(state.canSave, isFalse);
    });
  });

  group('typing', () {
    test('titleChanged and bodyChanged update the text', () async {
      final states = await statesEmittedBy(NoteEditorCubit(), (cubit) {
        cubit
          ..titleChanged('T')
          ..bodyChanged('B');
      });
      expect(states.last.title, 'T');
      expect(states.last.body, 'B');
      expect(states.last.savedTitle, isEmpty);
    });

    test('can save only when both fields have text and something changed', () {
      final cubit = NoteEditorCubit();
      cubit.titleChanged('Title');
      expect(cubit.state.canSave, isFalse, reason: 'body is empty');
      cubit.bodyChanged('Body');
      expect(cubit.state.canSave, isTrue);
    });

    test('spaces only count as empty', () {
      final cubit = NoteEditorCubit()
        ..titleChanged('   ')
        ..bodyChanged('Body');
      expect(cubit.state.canSave, isFalse);
      cubit.titleChanged(' Title ');
      expect(cubit.state.canSave, isTrue);
    });

    test('typing the saved text back means no changes and nothing to save', () {
      final cubit = NoteEditorCubit(
        note: testNote(1, title: 'Groceries', body: 'milk'),
      )..titleChanged('Shopping');
      expect(cubit.state.hasChanges, isTrue);
      expect(cubit.state.canSave, isTrue);

      cubit.titleChanged('Groceries');
      expect(cubit.state.hasChanges, isFalse);
      expect(cubit.state.canSave, isFalse);
    });

    test('clearing a field of an existing note blocks saving', () {
      final cubit = NoteEditorCubit(
        note: testNote(1, title: 'Groceries', body: 'milk'),
      )..bodyChanged('');
      expect(cubit.state.hasChanges, isTrue);
      expect(cubit.state.canSave, isFalse);
    });
  });

  group('mode', () {
    test('toggleMode switches to view and back, keeping the text', () async {
      final cubit = NoteEditorCubit()..titleChanged('Draft');
      final states = await statesEmittedBy(cubit, (cubit) {
        cubit
          ..toggleMode()
          ..toggleMode();
      });
      expect(states.map((state) => state.mode), [
        NoteEditorMode.view,
        NoteEditorMode.edit,
      ]);
      expect(states.every((state) => state.title == 'Draft'), isTrue);
    });
  });

  test('state equality and hash code follow every field', () {
    const a = NoteEditorState(
      mode: NoteEditorMode.edit,
      title: 'T',
      body: 'B',
      savedTitle: 'T',
      savedBody: 'B',
    );
    expect(a, a.copyWith());
    expect(a.hashCode, a.copyWith().hashCode);
    expect(a, isNot(a.copyWith(title: 'X')));
    expect(a, isNot(a.copyWith(mode: NoteEditorMode.view)));
  });

  test('calls after close are ignored instead of throwing', () async {
    final cubit = NoteEditorCubit();
    await cubit.close();
    expect(() => cubit.titleChanged('T'), returnsNormally);
    expect(() => cubit.bodyChanged('B'), returnsNormally);
    expect(cubit.toggleMode, returnsNormally);
  });
}
