# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Simple Flutter notes app, built as a test task for a Middle Flutter Developer position. README.md describes the planned UX improvements over the Figma design (Screens 01–14). Check it before building any screen.

The user directs the implementation step by step. Implement only the step asked for, and don't scaffold screens, layers or packages ahead of time.

## Commands

```bash
flutter pub get
flutter run
flutter analyze                      # lints: package:flutter_lints/flutter.yaml
flutter test
flutter test test/path/to_test.dart  # single file
flutter test --plain-name "name"     # single test by name
dart format lib test
dart run build_runner build --delete-conflicting-outputs   # after changing any @JsonSerializable class
```

Generated `*.g.dart` files are committed. Regenerate them, never edit them by hand.

## Architecture

`lib/` is split into `core/`, `data/`, `domain/`, `presentation/`. In practice, persistence is **HydratedBloc only**: there are no repositories, use cases or data sources, so don't add them.

- **`domain/model/note_model.dart`**: `NoteModel` (`id`, `title`, `body`, `createdAt`, `updatedAt`, `isFavorite`). `@JsonSerializable` with a hand-written `copyWith` and `==`/`hashCode`. Title and body are plain strings, with no rich text or markdown.
- **`presentation/global_blocs/notes/`**: `NotesBloc extends HydratedBloc`, the single source of truth for notes. Events and state are `part` files of `notes_bloc.dart`, so the generated `notes_bloc.g.dart` serializes `NotesState` (`notes`, `sortBy`). Derived lists (`sortedNotes`, `favoriteNotes`) are getters on the state.
- **`main.dart`**: initializes `HydratedBloc.storage`, using the documents directory, or web storage on web.
- **`presentation/app.dart`**: `NoteApp` wraps `MaterialApp.router` in `BlocProvider<NotesBloc>`, so the bloc is global to every route.
- **`presentation/utils/router/`**: `AppRoutes` holds the path constants and `AppRouter.router` the go_router config. Routes without a real screen yet use `_PlaceholderPage` with a TODO. `/note` serves both create and edit: no `id` query parameter means create (`AppRoutes.note` / `AppRoutes.noteById(id)`).
- **`presentation/utils/theme/theme_manager.dart`**: `ThemeManager.getTheme()` (static) is the single place for styling: color scheme, AppBar, IconButton and text theme. Prefer theme-level styling over styling individual widgets.
- **`presentation/resources/`**: `AppColors`, `AppFontSizes` (small/medium/large), `AppSizes` (padding/radius small/medium/large). These are non-instantiable classes of `static const` values. Use them; don't hard-code values.
- **`presentation/screens/<screen>/`**: one folder per screen, split like this:
  - `view/`: the UI class (`<screen>_screen_view.dart`).
  - `view_model/`: the screen's own Cubit/Bloc and its state, used for screen-local UI state such as the note editor's view/edit mode. Data that outlives the screen belongs in the global `NotesBloc`. The router creates the cubit with a `BlocProvider` around the screen view.
  - `components/`: custom widgets used only by this screen. Create it only when such a widget exists. Widgets shared between screens go in `presentation/widgets/`.
- **`presentation/widgets/`**: shared widgets. `StyledText(text, size: AppTextSize.small|medium|large)` is the text widget to use. It maps sizes to the theme's `bodyMedium`/`titleMedium`/`titleLarge`, which come from `AppFontSizes`.

## Conventions

- Screen classes and files end in `View` / `_view.dart` (e.g. `HomeScreenView`). `StyledText` is a deliberate exception. Ask before naming new shared widgets.
- No third-party UI packages. All UI comes from the Flutter SDK.
- No tooltips on any widget.
- Always ask the user which scrolling widget to use (`SingleChildScrollView`, `ListView`, `ListView.builder`, slivers, ...) before adding scrolling. Short forms of `TextFormField`s use `SingleChildScrollView` + `Column`: a lazy `ListView` disposes off-screen unfocused fields and rebuilds them from a stale `initialValue`.
- No `Dismissible`. Swipe to delete must be custom (e.g. `GestureDetector` + `AnimationController`).
- Resource classes and `ThemeManager` use a private constructor (`ClassName._()`).
- Imports within `lib/` are relative.
- Always give bloc widgets an explicit generic type: `BlocProvider<NotesBloc>(...)`, `BlocBuilder<NoteEditorCubit, NoteEditorState>(...)`, `context.read<NotesBloc>()`.
