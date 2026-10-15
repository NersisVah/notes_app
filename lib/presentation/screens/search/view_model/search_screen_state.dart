part of 'search_screen_cubit.dart';

class SearchScreenState {
  const SearchScreenState({this.query = ''});

  /// Text exactly as typed, used to show or hide the clear button.
  final String query;

  /// Notes whose title or body contains [query], ignoring case and
  /// surrounding spaces, newest updated first. A blank query matches all
  /// notes.
  List<NoteModel> results(List<NoteModel> notes) {
    final term = query.trim().toLowerCase();

    return notes
        .where(
          (note) =>
              term.isEmpty ||
              note.title.toLowerCase().contains(term) ||
              note.body.toLowerCase().contains(term),
        )
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchScreenState && other.query == query;

  @override
  int get hashCode => query.hashCode;
}
