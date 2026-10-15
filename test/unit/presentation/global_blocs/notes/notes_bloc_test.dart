import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notes_app/domain/model/note_model.dart';
import 'package:notes_app/presentation/global_blocs/notes/notes_bloc.dart';

import '../../../../helpers/bloc_states.dart';
import '../../../../helpers/memory_storage.dart';
import '../../../../helpers/test_notes.dart';

void main() {
  late MemoryStorage storage;

  setUp(() => HydratedBloc.storage = storage = MemoryStorage());

  /// A bloc that starts with [notes] already saved, as after a relaunch.
  NotesBloc blocWith(List<NoteModel> notes) {
    storage.values['NotesBloc'] = NotesState(notes: notes).toJson();
    return NotesBloc();
  }

  group('initial state', () {
    test('is empty when nothing is saved', () {
      expect(NotesBloc().state.notes, isEmpty);
    });

    test('restores the saved notes', () {
      final bloc = blocWith([testNote(1), testNote(2, isFavorite: true)]);
      expect(bloc.state.notes, [testNote(1), testNote(2, isFavorite: true)]);
    });
  });

  group('NoteAdded', () {
    test(
      'adds a note with a new id and equal created and updated dates',
      () async {
        final states = await statesEmittedBy(
          NotesBloc(),
          (bloc) => bloc.add(const NoteAdded(title: 'Groceries', body: 'milk')),
        );

        final note = states.single.notes.single;
        expect(note.title, 'Groceries');
        expect(note.body, 'milk');
        expect(note.isFavorite, isFalse);
        expect(note.id, isNotEmpty);
        expect(note.createdAt, note.updatedAt);
      },
    );

    test('keeps existing notes and gives every note its own id', () async {
      final bloc = blocWith([testNote(1)]);
      final states = await statesEmittedBy(bloc, (bloc) {
        bloc
          ..add(const NoteAdded(title: 'A', body: 'a'))
          ..add(const NoteAdded(title: 'B', body: 'b'));
      });

      final notes = states.last.notes;
      expect(notes, hasLength(3));
      expect(notes.first, testNote(1));
      expect(notes.map((note) => note.id).toSet(), hasLength(3));
    });
  });

  group('NoteUpdated', () {
    test('changes title, body and updated date of that note only', () async {
      final bloc = blocWith([testNote(1), testNote(2)]);
      final states = await statesEmittedBy(
        bloc,
        (bloc) => bloc.add(
          const NoteUpdated(id: 'note-1', title: 'New', body: 'new body'),
        ),
      );

      final updated = states.single.notes.first;
      expect(updated.title, 'New');
      expect(updated.body, 'new body');
      expect(updated.id, 'note-1');
      expect(updated.createdAt, testNote(1).createdAt);
      expect(updated.updatedAt.isAfter(testNote(1).updatedAt), isTrue);
      expect(updated.isFavorite, isFalse);
      expect(states.single.notes.last, testNote(2));
    });

    test('keeps the favorite flag', () async {
      final bloc = blocWith([testNote(1, isFavorite: true)]);
      final states = await statesEmittedBy(
        bloc,
        (bloc) =>
            bloc.add(const NoteUpdated(id: 'note-1', title: 'T', body: 'B')),
      );
      expect(states.single.notes.single.isFavorite, isTrue);
    });

    test('an unknown id changes nothing', () async {
      final bloc = blocWith([testNote(1)]);
      final states = await statesEmittedBy(
        bloc,
        (bloc) =>
            bloc.add(const NoteUpdated(id: 'missing', title: 'T', body: 'B')),
      );
      // A bloc's first emit goes through even when the state is equal, so
      // check that whatever was emitted holds the same notes.
      expect(
        states.every((state) => state == NotesState(notes: [testNote(1)])),
        isTrue,
      );
      expect(bloc.state.notes, [testNote(1)]);
    });
  });

  group('NoteDeleted', () {
    test('removes only that note', () async {
      final bloc = blocWith([testNote(1), testNote(2)]);
      final states = await statesEmittedBy(
        bloc,
        (bloc) => bloc.add(const NoteDeleted('note-1')),
      );
      expect(states.single.notes, [testNote(2)]);
    });

    test('an unknown id changes nothing', () async {
      final bloc = blocWith([testNote(1)]);
      final states = await statesEmittedBy(
        bloc,
        (bloc) => bloc.add(const NoteDeleted('missing')),
      );
      // A bloc's first emit goes through even when the state is equal, so
      // check that whatever was emitted holds the same notes.
      expect(
        states.every((state) => state == NotesState(notes: [testNote(1)])),
        isTrue,
      );
      expect(bloc.state.notes, [testNote(1)]);
    });
  });

  group('NoteFavoriteToggled', () {
    test('favorites and then unfavorites the note', () async {
      final bloc = blocWith([testNote(1), testNote(2)]);
      final states = await statesEmittedBy(bloc, (bloc) {
        bloc
          ..add(const NoteFavoriteToggled('note-1'))
          ..add(const NoteFavoriteToggled('note-1'));
      });

      expect(states, hasLength(2));
      expect(states.first.notes.first.isFavorite, isTrue);
      expect(states.last.notes.first.isFavorite, isFalse);
      expect(states.first.notes.last, testNote(2));
    });

    test('does not change the text or dates', () async {
      final bloc = blocWith([testNote(1)]);
      final states = await statesEmittedBy(
        bloc,
        (bloc) => bloc.add(const NoteFavoriteToggled('note-1')),
      );
      expect(
        states.single.notes.single,
        testNote(1).copyWith(isFavorite: true),
      );
    });
  });

  test('NotesState equality and hash code follow the notes', () {
    final a = NotesState(notes: [testNote(1)]);
    expect(a, NotesState(notes: [testNote(1)]));
    expect(a.hashCode, NotesState(notes: [testNote(1)]).hashCode);
    expect(a, isNot(NotesState(notes: [testNote(2)])));
  });

  group('persistence', () {
    test('every change is written to storage', () async {
      final bloc = NotesBloc();
      await statesEmittedBy(
        bloc,
        (bloc) => bloc.add(const NoteAdded(title: 'Saved', body: 'b')),
      );
      final saved = NotesState.fromJson(
        Map<String, dynamic>.from(storage.values['NotesBloc'] as Map),
      );
      expect(saved.notes.single.title, 'Saved');
    });

    test('toJson and fromJson round-trip the state', () {
      final state = NotesState(
        notes: [testNote(1), testNote(2, isFavorite: true)],
      );
      final bloc = NotesBloc();
      expect(bloc.fromJson(bloc.toJson(state)!), state);
    });

    test('older saved data with extra keys still loads', () {
      final json = NotesState(notes: [testNote(1)]).toJson()
        ..['sortBy'] = 'createdAt';
      expect(NotesState.fromJson(json).notes, [testNote(1)]);
    });
  });
}
