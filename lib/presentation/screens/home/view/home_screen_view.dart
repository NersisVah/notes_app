import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/model/note_model.dart';
import '../../../global_blocs/notes/notes_bloc.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/app_sizes.dart';
import '../../../utils/router/app_routes.dart';
import '../../../widgets/confirmation_dialog_view.dart';
import '../../../widgets/note_card_view.dart';
import '../../../widgets/styled_text.dart';
import '../view_model/home_screen_cubit.dart';

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  /// The swipe hint plays on the first card only once per app launch.
  static bool _swipeHintShown = false;

  /// Returns the id of the card that should play the swipe hint.
  static String? _takeHintNoteId(String firstNoteId) {
    if (_swipeHintShown) return null;
    _swipeHintShown = true;
    return firstNoteId;
  }

  Future<bool> _confirmDelete(BuildContext context, NoteModel note) async {
    final confirmed = await ConfirmationDialogView.show(
      context,
      message: 'Delete this note?',
      confirmLabel: 'Delete',
      isDelete: true,
    );
    if (confirmed && context.mounted) {
      context.read<NotesBloc>().add(NoteDeleted(note.id));
    }
    return confirmed;
  }

  Widget _selectableContainer(
    BuildContext context,
    String label,
    NotesFilter value,
    NotesFilter selected,
  ) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => context.read<HomeScreenCubit>().filterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: StyledText(
          label,
          size: AppTextSize.small,
          color: isSelected ? AppColors.scaffoldBackground : AppColors.white,
        ),
      ),
    );
  }

  BoxConstraints _bottomSheetConstraints(BuildContext context) =>
      BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(context).height *
            AppSizes.bottomSheetMaxHeightFactor,
      );

  /// One feature in the info sheet: an icon tile, a title and a short line.
  Widget _infoRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StyledText(title, size: AppTextSize.small),
              StyledText(
                description,
                size: AppTextSize.small,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInfoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: _bottomSheetConstraints(context),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingLarge,
            0,
            AppSizes.paddingLarge,
            AppSizes.paddingLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StyledText('Welcome to Notes', size: AppTextSize.medium),
              const SizedBox(height: AppSizes.paddingSmall),
              const StyledText(
                'A simple place to keep your thoughts.',
                size: AppTextSize.small,
                color: AppColors.grey,
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              _infoRow(
                Icons.add,
                'Create notes',
                'Give each note a title and write anything in the body.',
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              _infoRow(
                Icons.star,
                'Keep favorites close',
                'Swipe a note to the right and tap the star.',
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              _infoRow(
                Icons.edit_outlined,
                'Change them anytime',
                'Open a note and tap the pencil to update it.',
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              _infoRow(
                Icons.search,
                'Find them fast',
                'Search by any word in a title or body.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final cubit = context.read<HomeScreenCubit>();
    final current = cubit.state.sortBy;

    showModalBottomSheet<void>(
      context: context,
      constraints: _bottomSheetConstraints(context),
      builder: (sheetContext) {
        Widget option(String label, NotesSortBy sortBy) => ListTile(
          title: StyledText(label, size: AppTextSize.small),
          trailing: sortBy == current
              ? const Icon(Icons.check, color: AppColors.primary)
              : null,
          // The current option does nothing: no ripple, no event, sheet stays.
          onTap: sortBy == current
              ? null
              : () {
                  cubit.sortChanged(sortBy);
                  Navigator.of(sheetContext).pop();
                },
        );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option('Date updated', NotesSortBy.updatedAt),
              option('Date created', NotesSortBy.createdAt),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: AppSizes.paddingLarge),
          child: StyledText('Notes', size: AppTextSize.large),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge,
              ),
              child: BlocBuilder<HomeScreenCubit, HomeScreenState>(
                buildWhen: (previous, current) =>
                    previous.filter != current.filter,
                builder: (context, homeState) => Row(
                  children: [
                    _selectableContainer(
                      context,
                      'All',
                      NotesFilter.all,
                      homeState.filter,
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    _selectableContainer(
                      context,
                      'Favorites',
                      NotesFilter.favorites,
                      homeState.filter,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.sort),
                      onPressed: () => _showSortSheet(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Expanded(
              child: BlocBuilder<HomeScreenCubit, HomeScreenState>(
                builder: (context, homeState) =>
                    BlocBuilder<NotesBloc, NotesState>(
                      builder: (context, notesState) {
                        final notes = homeState.visibleNotes(notesState.notes);
                        if (notes.isEmpty) {
                          return Center(
                            child: StyledText(
                              textAlign: TextAlign.center,
                              homeState.filter == NotesFilter.all
                                  ? 'Create your first note!'
                                  : 'No favorite notes yet.',
                              size: AppTextSize.medium,
                            ),
                          );
                        }

                        final hintNoteId = _takeHintNoteId(notes.first.id);

                        return ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            AppSizes.paddingLarge,
                            0,
                            AppSizes.paddingLarge,
                            AppSizes.floatingActionButtonClearance +
                                MediaQuery.paddingOf(context).bottom,
                          ),
                          itemCount: notes.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSizes.paddingSmall),
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return NoteCardView(
                              key: ValueKey(note.id),
                              title: note.title,
                              isFavorite: note.isFavorite,
                              showHint: note.id == hintNoteId,
                              onTap: () => context.push(
                                AppRoutes.noteDetailsById(note.id),
                              ),
                              onFavoriteToggled: () => context
                                  .read<NotesBloc>()
                                  .add(NoteFavoriteToggled(note.id)),
                              onDeleteRequested: () =>
                                  _confirmDelete(context, note),
                            );
                          },
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.note),
        child: const Icon(
          Icons.add,
          shadows: [
            Shadow(
              color: AppColors.shadow,
              blurRadius: AppSizes.floatingActionButtonIconShadowBlurRadius,
            ),
          ],
        ),
      ),
    );
  }
}
