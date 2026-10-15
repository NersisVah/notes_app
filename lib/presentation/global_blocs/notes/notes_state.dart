part of 'notes_bloc.dart';

@JsonSerializable(explicitToJson: true)
class NotesState {
  const NotesState({this.notes = const []});

  factory NotesState.fromJson(Map<String, dynamic> json) =>
      _$NotesStateFromJson(json);

  final List<NoteModel> notes;

  Map<String, dynamic> toJson() => _$NotesStateToJson(this);

  NotesState copyWith({List<NoteModel>? notes}) {
    return NotesState(notes: notes ?? this.notes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotesState && listEquals(other.notes, notes);

  @override
  int get hashCode => Object.hashAll(notes);
}
