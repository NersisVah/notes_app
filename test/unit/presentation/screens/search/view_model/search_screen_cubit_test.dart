import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/presentation/screens/search/view_model/search_screen_cubit.dart';

import '../../../../../helpers/bloc_states.dart';
import '../../../../../helpers/test_notes.dart';

void main() {
  group('SearchScreenCubit', () {
    test('starts with an empty query', () {
      expect(SearchScreenCubit().state.query, isEmpty);
    });

    test(
      'queryChanged keeps the text as typed and cleared resets it',
      () async {
        final states = await statesEmittedBy(SearchScreenCubit(), (cubit) {
          cubit
            ..queryChanged(' Milk')
            ..cleared();
        });
        expect(states.map((state) => state.query), [' Milk', '']);
      },
    );

    test('calls after close are ignored instead of throwing', () async {
      final cubit = SearchScreenCubit();
      await cubit.close();
      expect(() => cubit.queryChanged('x'), returnsNormally);
      expect(cubit.cleared, returnsNormally);
    });
  });

  test('SearchScreenState equality and hash code follow the query', () {
    expect(
      const SearchScreenState(query: 'a'),
      const SearchScreenState(query: 'a'),
    );
    expect(
      const SearchScreenState(query: 'a').hashCode,
      const SearchScreenState(query: 'a').hashCode,
    );
    expect(
      const SearchScreenState(query: 'a'),
      isNot(const SearchScreenState()),
    );
  });

  group('SearchScreenState.results', () {
    final notes = [
      testNote(1, title: 'Shopping list', body: 'milk and eggs'),
      testNote(2, title: 'Ideas', body: 'Buy MILK later'),
      testNote(3, title: 'Work', body: 'meeting notes'),
    ];

    List<String> ids(String query) => SearchScreenState(
      query: query,
    ).results(notes).map((note) => note.id).toList();

    test('a blank query returns every note, newest updated first', () {
      expect(ids(''), ['note-3', 'note-2', 'note-1']);
      expect(ids('   '), ['note-3', 'note-2', 'note-1']);
    });

    test('matches the title or the body, ignoring case and outer spaces', () {
      expect(ids('  MiLk '), ['note-2', 'note-1']);
      expect(ids('work'), ['note-3']);
    });

    test('returns nothing when no note matches', () {
      expect(ids('zzz'), isEmpty);
    });
  });
}
