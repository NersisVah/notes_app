import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/model/note_model.dart';

part 'home_screen_state.dart';

/// Holds how the Home list is filtered and sorted. Not persisted: every launch
/// starts with all notes, newest updated first.
class HomeScreenCubit extends Cubit<HomeScreenState> {
  HomeScreenCubit() : super(const HomeScreenState());

  void filterChanged(NotesFilter filter) {
    if (!isClosed) emit(state.copyWith(filter: filter));
  }

  void sortChanged(NotesSortBy sortBy) {
    if (!isClosed) emit(state.copyWith(sortBy: sortBy));
  }
}
