import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'global_blocs/notes/notes_bloc.dart';
import 'utils/router/app_router.dart';
import 'utils/theme/theme_manager.dart';

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotesBloc>(
      create: (_) => NotesBloc(),
      child: MaterialApp.router(
        title: 'Notes',
        debugShowCheckedModeBanner: false,
        theme: ThemeManager.getTheme(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
