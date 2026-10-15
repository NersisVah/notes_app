import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/model/note_model.dart';

part 'note_editor_state.dart';

class NoteEditorCubit extends Cubit<NoteEditorState> {
  /// A new note ([note] is null) starts in edit mode, an existing one in view
  /// mode with its title and body.
  NoteEditorCubit({NoteModel? note})
    : super(
        NoteEditorState(
          mode: note == null ? NoteEditorMode.edit : NoteEditorMode.view,
          title: note?.title ?? '',
          body: note?.body ?? '',
          savedTitle: note?.title ?? '',
          savedBody: note?.body ?? '',
        ),
      );

  void toggleMode() {
    emit(
      state.copyWith(
        mode: state.isEditing ? NoteEditorMode.view : NoteEditorMode.edit,
      ),
    );
  }

  void titleChanged(String title) => emit(state.copyWith(title: title));

  void bodyChanged(String body) => emit(state.copyWith(body: body));
}
