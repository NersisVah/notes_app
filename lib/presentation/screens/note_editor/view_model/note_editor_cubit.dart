import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/model/note_model.dart';

part 'note_editor_state.dart';

class NoteEditorCubit extends Cubit<NoteEditorState> {
  /// Always starts in edit mode: notes are read on the details screen, and
  /// the editor is opened only to create or change one.
  NoteEditorCubit({NoteModel? note})
    : super(
        NoteEditorState(
          mode: NoteEditorMode.edit,
          title: note?.title ?? '',
          body: note?.body ?? '',
          savedTitle: note?.title ?? '',
          savedBody: note?.body ?? '',
        ),
      );

  void toggleMode() {
    if (!isClosed) {
      emit(
        state.copyWith(
          mode: state.isEditing ? NoteEditorMode.view : NoteEditorMode.edit,
        ),
      );
    }
  }

  void titleChanged(String title) {
    if (!isClosed) emit(state.copyWith(title: title));
  }

  void bodyChanged(String body) {
    if (!isClosed) emit(state.copyWith(body: body));
  }
}
