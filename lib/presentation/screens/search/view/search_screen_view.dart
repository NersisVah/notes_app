import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/model/note_model.dart';
import '../../../global_blocs/notes/notes_bloc.dart';
import '../../../resources/app_sizes.dart';
import '../../../utils/router/app_routes.dart';
import '../../../widgets/confirmation_dialog_view.dart';
import '../../../widgets/note_card_view.dart';
import '../../../widgets/styled_text.dart';
import '../view_model/search_screen_cubit.dart';

class SearchScreenView extends StatefulWidget {
  const SearchScreenView({super.key});

  @override
  State<SearchScreenView> createState() => _SearchScreenViewState();
}

class _SearchScreenViewState extends State<SearchScreenView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<SearchScreenCubit>().cleared();
  }

  Future<bool> _confirmDelete(NoteModel note) async {
    final confirmed = await ConfirmationDialogView.show(
      context,
      message: 'Delete this note?',
      confirmLabel: 'Delete',
      isDelete: true,
    );
    if (confirmed && mounted) {
      context.read<NotesBloc>().add(NoteDeleted(note.id));
    }
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingLarge,
                AppSizes.paddingMedium,
                AppSizes.paddingLarge,
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Expanded(
                    child:
                        BlocSelector<
                          SearchScreenCubit,
                          SearchScreenState,
                          bool
                        >(
                          selector: (state) => state.query.isNotEmpty,
                          builder: (context, hasText) => TextField(
                            controller: _controller,
                            autofocus: true,
                            onChanged: context
                                .read<SearchScreenCubit>()
                                .queryChanged,
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            textInputAction: TextInputAction.search,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                              labelText: 'Search notes',
                              isDense: true,
                              suffixIcon: hasText
                                  ? GestureDetector(
                                      onTap: _clear,
                                      child: const Icon(Icons.close),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                  ),
                ],
              ),
            ),
            // Fixed gap outside the list, so scrolled cards never touch the
            // widgets above.
            const SizedBox(height: AppSizes.paddingMedium),
            Expanded(
              child: BlocBuilder<SearchScreenCubit, SearchScreenState>(
                builder: (context, searchState) =>
                    BlocBuilder<NotesBloc, NotesState>(
                      builder: (context, notesState) {
                        final notes = searchState.results(notesState.notes);

                        if (notes.isEmpty) {
                          return const Center(
                            child: StyledText(
                              textAlign: TextAlign.center,
                              'No notes match your search',
                              size: AppTextSize.small,
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.paddingLarge,
                            0,
                            AppSizes.paddingLarge,
                            AppSizes.paddingLarge,
                          ),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return Padding(
                              key: ValueKey(note.id),
                              // No gap after the last card; the list's
                              // bottom padding follows it.
                              padding: EdgeInsets.only(
                                bottom: index == notes.length - 1
                                    ? 0
                                    : AppSizes.paddingSmall,
                              ),
                              child: NoteCardView(
                                title: note.title,
                                isFavorite: note.isFavorite,
                                onTap: () =>
                                    context.push(AppRoutes.noteById(note.id)),
                                onFavoriteToggled: () => context
                                    .read<NotesBloc>()
                                    .add(NoteFavoriteToggled(note.id)),
                                onDeleteRequested: () => _confirmDelete(note),
                              ),
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
    );
  }
}
