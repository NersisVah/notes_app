part of 'home_screen_cubit.dart';

enum NotesFilter { all, favorites }

enum NotesSortBy { createdAt, updatedAt }

class HomeScreenState {
  const HomeScreenState({
    this.filter = NotesFilter.all,
    this.sortBy = NotesSortBy.updatedAt,
  });

  final NotesFilter filter;
  final NotesSortBy sortBy;

  /// [notes] filtered by [filter], newest first by the [sortBy] date.
  List<NoteModel> visibleNotes(List<NoteModel> notes) {
    DateTime dateOf(NoteModel note) =>
        sortBy == NotesSortBy.createdAt ? note.createdAt : note.updatedAt;

    return notes
        .where((note) => filter == NotesFilter.all || note.isFavorite)
        .toList()
      ..sort((a, b) => dateOf(b).compareTo(dateOf(a)));
  }

  HomeScreenState copyWith({NotesFilter? filter, NotesSortBy? sortBy}) {
    return HomeScreenState(
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeScreenState &&
          other.filter == filter &&
          other.sortBy == sortBy;

  @override
  int get hashCode => Object.hash(filter, sortBy);
}
