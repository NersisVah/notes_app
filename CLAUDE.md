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
flutter test --exclude-tags golden   # skip golden image tests
flutter test --update-goldens test/golden   # regenerate golden images after an intended UI change
dart format lib test
dart run build_runner build --delete-conflicting-outputs   # after changing any @JsonSerializable class
```

Generated `*.g.dart` files are committed. Regenerate them, never edit them by hand.

Tests are grouped by type (see `test/README.md`): `test/unit/` and `test/widget/presentation/` mirror `lib/`; `test/widget/flows/` holds the cross-screen state-management flow; `test/golden/<screen>/goldens/<state>/w<width>_x<scale>.png` are committed images (Home list, note details). Start the app with `pumpNotesApp` (`test/helpers/notes_app_harness.dart`), build notes with `testNote`, and check bloc/cubit emissions with `statesEmittedBy` (package:bloc_test can't be installed next to json_serializable/build_runner). Goldens use the fonts in `test/fonts/` and `withRealShadows`. The router is a single static instance, so `pumpNotesApp` sends it to Home first.

## Architecture

`lib/` is split into `core/`, `data/`, `domain/`, `presentation/`. In practice, persistence is **HydratedBloc only**: there are no repositories, use cases or data sources, so don't add them.

- **`domain/model/note_model.dart`**: `NoteModel` (`id`, `title`, `body`, `createdAt`, `updatedAt`, `isFavorite`). `@JsonSerializable` with a hand-written `copyWith` and `==`/`hashCode`. Title and body are plain strings, with no rich text or markdown.
- **`presentation/global_blocs/notes/`**: `NotesBloc extends HydratedBloc`, the single source of truth for notes. Events and state are `part` files of `notes_bloc.dart`, so the generated `notes_bloc.g.dart` serializes `NotesState`, which persists only `notes`. View preferences such as the Home filter and sort order are not persisted; they live in the screen's cubit (`HomeScreenCubit`, which filters and sorts with `HomeScreenState.visibleNotes`).
- **`main.dart`**: initializes `HydratedBloc.storage`, using the documents directory, or web storage on web.
- **`presentation/app.dart`**: `NoteApp` wraps `MaterialApp.router` in `BlocProvider<NotesBloc>`, so the bloc is global to every route.
- **`presentation/utils/router/`**: `AppRoutes` holds the path constants and `AppRouter.router` the go_router config. Note cards open `/note-details?id=` (`AppRoutes.noteDetailsById`), a read-only screen with edit, favorite and delete. `/note` is the editor for both create and edit: no `id` query parameter means create (`AppRoutes.note` / `AppRoutes.noteById(id)`); it always starts in edit mode and pops back to the screen that opened it after saving.
- **`presentation/utils/theme/theme_manager.dart`**: `ThemeManager.getTheme()` (static) is the single place for styling: color scheme, AppBar, IconButton and text theme. Prefer theme-level styling over styling individual widgets.
- **`presentation/resources/`**: `AppColors`, `AppFontSizes` (small/medium/large), `AppSizes` (padding/radius small/medium/large). These are non-instantiable classes of `static const` values. Use them; don't hard-code values.
- **`presentation/screens/<screen>/`**: one folder per screen, split like this:
  - `view/`: the UI class (`<screen>_screen_view.dart`).
  - `view_model/`: the screen's own Cubit/Bloc and its state, used for screen-local UI state such as the note editor's view/edit mode. Data that outlives the screen belongs in the global `NotesBloc`. The router creates the cubit with a `BlocProvider` around the screen view.
  - `components/`: custom widgets used only by this screen. Create it only when such a widget exists. Widgets shared between screens go in `presentation/widgets/`.
- **`presentation/widgets/`**: shared widgets. `StyledText(text, size: AppTextSize.small|medium|large)` is the text widget to use. It maps sizes to the theme's `bodyMedium`/`titleMedium`/`titleLarge`, which come from `AppFontSizes`.

## Text sizes

Text uses `StyledText(text, size: AppTextSize.small|medium|large)`; text fields can't, so they take the same styles from `Theme.of(context).textTheme` (`titleLarge` = large, `titleMedium` = medium, `bodyMedium` = small). The values live only in `AppFontSizes`.

| Size | Used for |
|---|---|
| `large` | Screen titles (AppBar), the note title on the details screen, the title field in the editor |
| `medium` | Note card titles, headings inside sheets and dialogs ("Welcome to Notes") |
| `small` | All body text: note body, body and search fields, pills, sort options, dialog messages and buttons, info rows, empty-state messages |
| `small` + `AppColors.grey` | Secondary text: subtitles and descriptions |

## Spacing and radii

Every padding, gap and radius comes from `AppSizes`; never hard-code numbers. Spacing follows three rules, one per size:

- **`paddingLarge` (24): distance from an edge.** Screen sides on every screen (AppBar title/leading padding, theme `actionsPadding`, top rows, lists, note form, `NoteContentView`), padding inside a dialog, and a list's bottom padding (on a screen with a floating action button, `floatingActionButtonClearance + MediaQuery.paddingOf(context).bottom` instead).
- **`paddingMedium` (16): vertical gap between stacked parts.** Status bar → top row on a screen without an AppBar, top row → list, title → body, icon → message → buttons in a dialog. Also the inner padding of controls: note card all around, pills horizontally.
- **`paddingSmall` (8): gap between neighbours.** Controls next to each other in a row (back button → search field, filter pills, dialog buttons, icons inside a card), between list items (never after the last one), and pills vertically.

Layout details that keep those rules true:
- The AppBar theme sets `titleSpacing: 0`, so a title or leading widget gets its own `Padding(left: paddingLarge)`. A padded leading button also needs `leadingWidth: paddingLarge + kMinInteractiveDimension` and a `Center`.
- A screen without an AppBar (Search) puts its top row in the body inside a `SafeArea` that keeps `top`.
- The top row → list gap is a fixed `SizedBox` outside the list, and the list's own top padding is 0, so scrolled items never touch the row.
- Dialogs are limited to `dialogMinWidth`–`dialogMaxWidth` (280–400) by the dialog theme, so they keep a pop-up size on tablets and in landscape.

**Radii:** `radiusSmall` for dialog buttons; `radiusMedium` for note cards and text field borders; `radiusLarge` for icon buttons, pills, dialogs and the top of bottom sheets.

## Conventions

- Screen classes and files end in `View` / `_view.dart` (e.g. `HomeScreenView`). `StyledText` is a deliberate exception. Ask before naming new shared widgets.
- No third-party UI packages. All UI comes from the Flutter SDK.
- No tooltips on any widget.
- Always ask before setting `maxLines` or `overflow` (ellipsis, fade, clip, ...) on any text.
- Always ask which scrolling widget to use (`SingleChildScrollView`, `ListView`, `ListView.builder`, slivers, ...) before adding scrolling. Short forms of `TextFormField`s use `SingleChildScrollView` + `Column`: a lazy `ListView` disposes off-screen unfocused fields and rebuilds them from a stale `initialValue`.
- No `Dismissible`. Swipe to delete must be custom (e.g. `GestureDetector` + `AnimationController`).
- Resource classes and `ThemeManager` use a private constructor (`ClassName._()`).
- Imports within `lib/` are relative.
- Don't use `context.watch`/`context.select` to listen to blocs; listen with `BlocBuilder`/`BlocSelector` placed around the exact widgets that depend on the state. `context.read` is fine for dispatching events and calling cubit methods.
- In every Cubit, guard each `emit(...)` with `if (!isClosed)`. Blocs don't need it: their event handlers emit through the `Emitter`, which already ignores emits after the bloc is closed.
- Always give bloc widgets an explicit generic type: `BlocProvider<NotesBloc>(...)`, `BlocBuilder<NoteEditorCubit, NoteEditorState>(...)`, `context.read<NotesBloc>()`.
