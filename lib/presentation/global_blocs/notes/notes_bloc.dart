import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/model/note_model.dart';

part 'notes_bloc.g.dart';
part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends HydratedBloc<NotesEvent, NotesState> {
  NotesBloc({Uuid uuid = const Uuid()})
    : _uuid = uuid,
      super(const NotesState()) {
    on<NoteAdded>(_onNoteAdded);
    on<NoteUpdated>(_onNoteUpdated);
    on<NoteDeleted>(_onNoteDeleted);
    on<NoteFavoriteToggled>(_onNoteFavoriteToggled);
    on<NotesSortChanged>(_onNotesSortChanged);
  }

  final Uuid _uuid;

  void _onNoteAdded(NoteAdded event, Emitter<NotesState> emit) {
    final now = DateTime.now();
    final note = NoteModel(
      id: _uuid.v4(),
      title: event.title,
      body: event.body,
      createdAt: now,
      updatedAt: now,
    );
    emit(state.copyWith(notes: [...state.notes, note]));
  }

  void _onNoteUpdated(NoteUpdated event, Emitter<NotesState> emit) {
    emit(
      state.copyWith(
        notes: [
          for (final note in state.notes)
            if (note.id == event.id)
              note.copyWith(
                title: event.title,
                body: event.body,
                updatedAt: DateTime.now(),
              )
            else
              note,
        ],
      ),
    );
  }

  void _onNoteDeleted(NoteDeleted event, Emitter<NotesState> emit) {
    emit(
      state.copyWith(
        notes: state.notes.where((note) => note.id != event.id).toList(),
      ),
    );
  }

  void _onNoteFavoriteToggled(
    NoteFavoriteToggled event,
    Emitter<NotesState> emit,
  ) {
    emit(
      state.copyWith(
        notes: [
          for (final note in state.notes)
            if (note.id == event.id)
              note.copyWith(isFavorite: !note.isFavorite)
            else
              note,
        ],
      ),
    );
  }

  void _onNotesSortChanged(NotesSortChanged event, Emitter<NotesState> emit) {
    emit(state.copyWith(sortBy: event.sortBy));
  }

  @override
  NotesState? fromJson(Map<String, dynamic> json) => NotesState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(NotesState state) => state.toJson();
}
