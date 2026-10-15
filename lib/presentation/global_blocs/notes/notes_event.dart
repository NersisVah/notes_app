part of 'notes_bloc.dart';

sealed class NotesEvent {
  const NotesEvent();
}

final class NoteAdded extends NotesEvent {
  const NoteAdded({required this.title, required this.body});

  final String title;
  final String body;
}

final class NoteUpdated extends NotesEvent {
  const NoteUpdated({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;
}

final class NoteDeleted extends NotesEvent {
  const NoteDeleted(this.id);

  final String id;
}

final class NoteFavoriteToggled extends NotesEvent {
  const NoteFavoriteToggled(this.id);

  final String id;
}
