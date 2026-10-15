import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../global_blocs/notes/notes_bloc.dart';
import '../../screens/home/view/home_screen_view.dart';
import '../../screens/home/view_model/home_screen_cubit.dart';
import '../../screens/note_editor/view/note_editor_screen_view.dart';
import '../../screens/note_editor/view_model/note_editor_cubit.dart';
import '../../screens/search/view/search_screen_view.dart';
import '../../screens/search/view_model/search_screen_cubit.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => BlocProvider<HomeScreenCubit>(
          create: (_) => HomeScreenCubit(),
          child: const HomeScreenView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => BlocProvider<SearchScreenCubit>(
          create: (_) => SearchScreenCubit(),
          child: const SearchScreenView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.note,
        builder: (context, state) {
          final noteId = state.uri.queryParameters[AppRoutes.noteIdParam];
          final note = context
              .read<NotesBloc>()
              .state
              .notes
              .where((note) => note.id == noteId)
              .firstOrNull;
          return BlocProvider<NoteEditorCubit>(
            create: (_) => NoteEditorCubit(note: note),
            child: NoteEditorScreenView(noteId: noteId),
          );
        },
      ),
    ],
  );
}
