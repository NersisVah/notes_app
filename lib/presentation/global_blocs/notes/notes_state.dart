part of 'notes_bloc.dart';

enum NotesSortBy { createdAt, updatedAt }

@JsonSerializable(explicitToJson: true)
class NotesState {
  const NotesState({
    this.notes = const [],
    this.sortBy = NotesSortBy.updatedAt,
  });

  factory NotesState.fromJson(Map<String, dynamic> json) =>
      _$NotesStateFromJson(json);

  final List<NoteModel> notes;
  final NotesSortBy sortBy;

  /// All notes, newest first by [sortBy].
  List<NoteModel> get sortedNotes {
    DateTime dateOf(NoteModel note) =>
        sortBy == NotesSortBy.createdAt ? note.createdAt : note.updatedAt;

    return [...notes]..sort((a, b) => dateOf(b).compareTo(dateOf(a)));
  }

  List<NoteModel> get favoriteNotes =>
      sortedNotes.where((note) => note.isFavorite).toList();

  Map<String, dynamic> toJson() => _$NotesStateToJson(this);

  NotesState copyWith({List<NoteModel>? notes, NotesSortBy? sortBy}) {
    return NotesState(
      notes: notes ?? this.notes,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotesState &&
          listEquals(other.notes, notes) &&
          other.sortBy == sortBy;

  @override
  int get hashCode => Object.hash(Object.hashAll(notes), sortBy);
}
