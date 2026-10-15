import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/presentation/screens/home/view_model/home_screen_cubit.dart';

import '../../../../../helpers/bloc_states.dart';
import '../../../../../helpers/test_notes.dart';

void main() {
  group('HomeScreenCubit', () {
    test('starts with all notes sorted by date updated', () {
      expect(HomeScreenCubit().state, const HomeScreenState());
      expect(const HomeScreenState().filter, NotesFilter.all);
      expect(const HomeScreenState().sortBy, NotesSortBy.updatedAt);
    });

    test('filterChanged and sortChanged emit the new choice', () async {
      final states = await statesEmittedBy(HomeScreenCubit(), (cubit) {
        cubit
          ..filterChanged(NotesFilter.favorites)
          ..sortChanged(NotesSortBy.createdAt)
          ..filterChanged(NotesFilter.all);
      });
      expect(states, const [
        HomeScreenState(filter: NotesFilter.favorites),
        HomeScreenState(
          filter: NotesFilter.favorites,
          sortBy: NotesSortBy.createdAt,
        ),
        HomeScreenState(sortBy: NotesSortBy.createdAt),
      ]);
    });

    test('choosing the current option keeps the same state', () async {
      final cubit = HomeScreenCubit();
      final states = await statesEmittedBy(cubit, (cubit) {
        cubit
          ..filterChanged(NotesFilter.all)
          ..sortChanged(NotesSortBy.updatedAt);
      });
      // A cubit's first emit goes through even when the state is equal; after
      // that, equal states are skipped.
      expect(states, hasLength(lessThanOrEqualTo(1)));
      expect(states.every((state) => state == const HomeScreenState()), isTrue);
      expect(cubit.state, const HomeScreenState());
    });

    test('calls after close are ignored instead of throwing', () async {
      final cubit = HomeScreenCubit();
      await cubit.close();
      expect(() => cubit.filterChanged(NotesFilter.favorites), returnsNormally);
      expect(() => cubit.sortChanged(NotesSortBy.createdAt), returnsNormally);
    });
  });

  test('HomeScreenState equality and hash code follow its fields', () {
    const a = HomeScreenState(filter: NotesFilter.favorites);
    expect(a, const HomeScreenState(filter: NotesFilter.favorites));
    expect(
      a.hashCode,
      const HomeScreenState(filter: NotesFilter.favorites).hashCode,
    );
    expect(a, isNot(const HomeScreenState()));
  });

  group('HomeScreenState.visibleNotes', () {
    // Note 1 was created first but edited last.
    final notes = [
      testNote(1, editedAfter: const Duration(days: 1)),
      testNote(2, isFavorite: true),
      testNote(3),
    ];

    List<String> ids(HomeScreenState state) =>
        state.visibleNotes(notes).map((note) => note.id).toList();

    test('all notes, newest updated first', () {
      expect(ids(const HomeScreenState()), ['note-1', 'note-3', 'note-2']);
    });

    test('all notes, newest created first', () {
      expect(ids(const HomeScreenState(sortBy: NotesSortBy.createdAt)), [
        'note-3',
        'note-2',
        'note-1',
      ]);
    });

    test('favorites only', () {
      expect(ids(const HomeScreenState(filter: NotesFilter.favorites)), [
        'note-2',
      ]);
    });

    test('does not change the given list', () {
      final copy = [...notes];
      const HomeScreenState(sortBy: NotesSortBy.createdAt).visibleNotes(notes);
      expect(notes, copy);
    });
  });
}
