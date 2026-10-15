import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../global_blocs/notes/notes_bloc.dart';
import '../../../resources/app_sizes.dart';
import '../../../utils/router/app_routes.dart';
import '../../../widgets/confirmation_dialog_view.dart';
import '../../../widgets/note_content_view.dart';
import '../components/note_form_view.dart';
import '../view_model/note_editor_cubit.dart';

/// Creates a new note when [noteId] is null, otherwise edits that note.
class NoteEditorScreenView extends StatelessWidget {
  const NoteEditorScreenView({super.key, this.noteId});

  final String? noteId;

  /// Leaves right away when nothing changed, otherwise asks first.
  Future<void> _onBack(BuildContext context) async {
    final hasChanges = context.read<NoteEditorCubit>().state.hasChanges;
    if (hasChanges) {
      final leave = await ConfirmationDialogView.show(
        context,
        message: 'Your changes will be lost. Leave without saving?',
        confirmLabel: 'Leave',
        cancelLabel: 'Stay',
      );
      if (!leave || !context.mounted) return;
    }
    context.pop();
  }

  Future<void> _onSave(BuildContext context) async {
    final save = await ConfirmationDialogView.show(
      context,
      message: 'Save changes?',
      confirmLabel: 'Save',
    );
    if (!save || !context.mounted) return;

    final state = context.read<NoteEditorCubit>().state;
    final id = noteId;
    context.read<NotesBloc>().add(
      id == null
          ? NoteAdded(title: state.title, body: state.body)
          : NoteUpdated(id: id, title: state.title, body: state.body),
    );
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    // Blocks the iOS swipe-back gesture. Android system back goes through
    // the same check as the AppBar back button.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: AppSizes.paddingLarge + kMinInteractiveDimension,
          leading: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSizes.paddingLarge),
              child: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _onBack(context),
              ),
            ),
          ),
          actions: [
            BlocBuilder<NoteEditorCubit, NoteEditorState>(
              buildWhen: (previous, current) => previous.mode != current.mode,
              builder: (context, state) => IconButton(
                icon: Icon(
                  state.isEditing
                      ? Icons.visibility_outlined
                      : Icons.edit_outlined,
                ),
                onPressed: () => context.read<NoteEditorCubit>().toggleMode(),
              ),
            ),
            BlocSelector<NoteEditorCubit, NoteEditorState, bool>(
              selector: (state) => state.canSave,
              builder: (context, canSave) => IconButton(
                icon: const Icon(Icons.save_outlined),
                onPressed: canSave ? () => _onSave(context) : null,
              ),
            ),
          ],
        ),
        body: BlocBuilder<NoteEditorCubit, NoteEditorState>(
          buildWhen: (previous, current) => previous.mode != current.mode,
          builder: (context, state) => state.isEditing
              ? const NoteFormView()
              : NoteContentView(title: state.title, body: state.body),
        ),
      ),
    );
  }
}
