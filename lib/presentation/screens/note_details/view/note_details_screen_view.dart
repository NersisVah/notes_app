import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/model/note_model.dart';
import '../../../global_blocs/notes/notes_bloc.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/app_sizes.dart';
import '../../../utils/router/app_routes.dart';
import '../../../widgets/confirmation_dialog_view.dart';
import '../../../widgets/note_content_view.dart';
import '../../../widgets/styled_text.dart';

/// Read-only note with edit, favorite and delete actions. Reads the note
/// from [NotesBloc], so edits and favorite changes show right away.
class NoteDetailsScreenView extends StatelessWidget {
  const NoteDetailsScreenView({super.key, required this.noteId});

  final String noteId;

  /// For example "15.10.2026 14:05", in the phone's local time.
  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final local = date.toLocal();
    return '${twoDigits(local.day)}.${twoDigits(local.month)}.${local.year} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  NoteModel? _findNote(NotesState state) =>
      state.notes.where((note) => note.id == noteId).firstOrNull;

  Future<void> _onDelete(BuildContext context) async {
    final confirmed = await ConfirmationDialogView.show(
      context,
      message: 'Delete this note?',
      confirmLabel: 'Delete',
      isDelete: true,
    );
    if (!confirmed || !context.mounted) return;

    context.read<NotesBloc>().add(NoteDeleted(noteId));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotesBloc, NotesState, NoteModel?>(
      selector: _findNote,
      builder: (context, note) => Scaffold(
        appBar: AppBar(
          leadingWidth: AppSizes.paddingLarge + kMinInteractiveDimension,
          leading: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSizes.paddingLarge),
              child: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          actions: [
            if (note != null) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(AppRoutes.noteById(noteId)),
              ),
              IconButton(
                icon: Icon(
                  note.isFavorite ? Icons.star : Icons.star_border,
                  color: AppColors.primary,
                ),
                onPressed: () =>
                    context.read<NotesBloc>().add(NoteFavoriteToggled(noteId)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.red),
                onPressed: () => _onDelete(context),
              ),
            ],
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: note == null
              ? const SizedBox.shrink()
              : NoteContentView(
                  title: note.title,
                  body: note.body,
                  footer: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StyledText(
                        'Created at: ${_formatDate(note.createdAt)}',
                        size: AppTextSize.small,
                        color: AppColors.grey,
                      ),
                      StyledText(
                        'Updated at: ${_formatDate(note.updatedAt)}',
                        size: AppTextSize.small,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
