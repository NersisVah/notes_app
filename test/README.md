# Tests

Tests are grouped by type. Inside `unit/` and `widget/`, folders mirror `lib/`, so a test sits at the same path as the code it covers.

| Folder | What it holds |
|---|---|
| `unit/` | Logic without UI: the note model, `NotesBloc` and every screen cubit with its state. |
| `widget/presentation/` | One screen or shared widget rendered in the real app: taps, swipes, typing, navigation, and the bloc state each action produces. |
| `widget/flows/` | One long flow across screens: add, update, favorite, unfavorite and delete notes, checking `NotesBloc`, the screen and saved storage after each step, then relaunching the app. |
| `golden/` | Screenshots compared with committed images (see below). |
| `helpers/` | Shared test code (see below). |
| `fonts/` | Roboto and Material Icons (Apache 2.0, licenses next to them), so golden images show real text and icons. |

## Helpers

| File | Use |
|---|---|
| `notes_app_harness.dart` | `pumpNotesApp(tester, notes:, size:, textScale:)` starts the real app on Home with notes already saved; `notesState(tester)` reads `NotesBloc`; `savedNotes(storage)` reads what HydratedBloc saved. |
| `test_notes.dart` | `testNote(index, …)` builds a note with a fixed id and local dates. |
| `bloc_states.dart` | `statesEmittedBy(bloc, act)` returns the states a bloc or cubit emitted. It stands in for `blocTest`, because package:bloc_test can't be installed next to this project's json_serializable and build_runner versions. |
| `memory_storage.dart` | In-memory storage for HydratedBloc. |
| `golden_fonts.dart`, `golden_helpers.dart` | Real fonts, the golden widths and text scales, and `withRealShadows`. |

A bloc or cubit always emits its first state even when it equals the current one; after that, equal states are skipped. Tests that check "nothing changed" therefore check the notes, not that nothing was emitted.

## Golden images

Every golden test renders a screen at widths 360 (phone) and 768 (tablet / landscape) and system text scales 1.0, 2.0 and 3.0. Images are named `w<width>_x<scale>.png` and grouped in one folder per content state:

- `golden/home_list/goldens/`
  - `empty/`: no notes yet
  - `favorites_empty/`: Favorites filter with no favorites
  - `few_notes/`: three short notes, one favorite
  - `long_and_many/`: twelve notes with long, wrapping titles
- `golden/note_details/goldens/`
  - `short_note/`: a short note, not a favorite, with its dates
  - `long_favorite/`: a favorite with a long title and a body longer than the screen

Open them to see the screens without running the app. They use real shadows (`withRealShadows`); Flutter tests otherwise draw every shadow as a solid black outline.

## Commands

```bash
flutter test                                   # everything
flutter test test/unit                         # one folder
flutter test --exclude-tags golden             # everything except goldens
flutter test --update-goldens test/golden      # regenerate images after an intended UI change
```

The images were generated on macOS. Other operating systems can render text and shadows with tiny differences and fail the comparison; regenerate them on macOS.
