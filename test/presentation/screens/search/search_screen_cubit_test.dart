import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/domain/model/note_model.dart';
import 'package:notes_app/presentation/screens/search/view_model/search_screen_cubit.dart';

NoteModel _note(String id, String title, String body, int updatedMinute) {
  final date = DateTime(2026, 1, 1, 0, updatedMinute);
  return NoteModel(
    id: id,
    title: title,
    body: body,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  final notes = [
    _note('1', 'Shopping list', 'milk and eggs', 1),
    _note('2', 'Ideas', 'Buy MILK later', 3),
    _note('3', 'Work', 'meeting notes', 2),
  ];

  group('SearchScreenState.results', () {
    test('blank query returns all notes, newest updated first', () {
      final ids = const SearchScreenState(
        query: '   ',
      ).results(notes).map((n) => n.id);
      expect(ids, ['2', '3', '1']);
    });

    test('matches title or body ignoring case and surrounding spaces', () {
      final ids = const SearchScreenState(
        query: '  MiLk ',
      ).results(notes).map((n) => n.id);
      expect(ids, ['2', '1']);
    });

    test('returns nothing when no note matches', () {
      expect(const SearchScreenState(query: 'zzz').results(notes), isEmpty);
    });
  });

  group('SearchScreenCubit', () {
    test('queryChanged stores the text as typed and cleared resets it', () {
      final cubit = SearchScreenCubit();
      cubit.queryChanged(' milk');
      expect(cubit.state.query, ' milk');
      cubit.cleared();
      expect(cubit.state.query, '');
      cubit.close();
    });

    test('does not emit after close', () async {
      final cubit = SearchScreenCubit();
      await cubit.close();
      expect(() => cubit.queryChanged('x'), returnsNormally);
    });
  });
}
