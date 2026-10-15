part of 'note_editor_cubit.dart';

enum NoteEditorMode { view, edit }

class NoteEditorState {
  const NoteEditorState({
    required this.mode,
    this.title = '',
    this.body = '',
    this.savedTitle = '',
    this.savedBody = '',
  });

  final NoteEditorMode mode;
  final String title;
  final String body;

  /// Title and body as they are stored, used to detect unsaved changes.
  final String savedTitle;
  final String savedBody;

  bool get isEditing => mode == NoteEditorMode.edit;

  bool get hasChanges => title != savedTitle || body != savedBody;

  /// There are changes, and title and body both contain more than whitespace.
  bool get canSave =>
      hasChanges && title.trim().isNotEmpty && body.trim().isNotEmpty;

  NoteEditorState copyWith({
    NoteEditorMode? mode,
    String? title,
    String? body,
  }) {
    return NoteEditorState(
      mode: mode ?? this.mode,
      title: title ?? this.title,
      body: body ?? this.body,
      savedTitle: savedTitle,
      savedBody: savedBody,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteEditorState &&
          other.mode == mode &&
          other.title == title &&
          other.body == body &&
          other.savedTitle == savedTitle &&
          other.savedBody == savedBody;

  @override
  int get hashCode => Object.hash(mode, title, body, savedTitle, savedBody);
}
