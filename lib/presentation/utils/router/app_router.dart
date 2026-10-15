import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        // TODO: replace with HomePage
        builder: (context, state) => const _PlaceholderPage('Home'),
      ),
      GoRoute(
        path: AppRoutes.search,
        // TODO: replace with SearchPage
        builder: (context, state) => const _PlaceholderPage('Search'),
      ),
      GoRoute(
        path: AppRoutes.newNote,
        // TODO: replace with NotePage for a new note
        builder: (context, state) => const _PlaceholderPage('New note'),
      ),
      GoRoute(
        path: AppRoutes.note,
        // TODO: replace with NotePage, passing state.pathParameters['id']
        builder: (context, state) =>
            _PlaceholderPage('Note ${state.pathParameters['id']}'),
      ),
    ],
  );
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
