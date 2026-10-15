import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/model/note_model.dart';

part 'search_screen_state.dart';

/// Holds the search query. Not persisted: Search always opens empty.
class SearchScreenCubit extends Cubit<SearchScreenState> {
  SearchScreenCubit() : super(const SearchScreenState());

  void queryChanged(String query) {
    if (!isClosed) emit(SearchScreenState(query: query));
  }

  void cleared() {
    if (!isClosed) emit(const SearchScreenState());
  }
}
