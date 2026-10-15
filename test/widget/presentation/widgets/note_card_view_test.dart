import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/presentation/widgets/note_card_view.dart';

void main() {
  late int taps;
  late int favoriteToggles;
  late int deleteRequests;
  late bool confirmDelete;

  setUp(() {
    taps = 0;
    favoriteToggles = 0;
    deleteRequests = 0;
    confirmDelete = false;
  });

  Future<void> pumpCard(
    WidgetTester tester, {
    bool isFavorite = false,
    bool showHint = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: NoteCardView(
                title: 'Groceries',
                isFavorite: isFavorite,
                showHint: showHint,
                onTap: () => taps++,
                onFavoriteToggled: () => favoriteToggles++,
                onDeleteRequested: () async {
                  deleteRequests++;
                  return confirmDelete;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  double cardLeft(WidgetTester tester) =>
      tester.getTopLeft(find.text('Groceries')).dx;

  testWidgets('shows the title and a filled or outlined star', (tester) async {
    await pumpCard(tester, isFavorite: true);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await pumpCard(tester);
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('tapping a closed card calls onTap', (tester) async {
    await pumpCard(tester);
    await tester.tap(find.text('Groceries'));
    expect(taps, 1);
  });

  testWidgets('dragging right to left does nothing', (tester) async {
    await pumpCard(tester);
    final rest = cardLeft(tester);
    await tester.drag(find.text('Groceries'), const Offset(-150, 0));
    await tester.pumpAndSettle();
    expect(cardLeft(tester), rest);
  });

  testWidgets('a short drag snaps closed, a longer one opens by 80', (
    tester,
  ) async {
    await pumpCard(tester);
    final rest = cardLeft(tester);

    await tester.drag(find.text('Groceries'), const Offset(20, 0));
    await tester.pumpAndSettle();
    expect(cardLeft(tester), rest);

    await tester.drag(find.text('Groceries'), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(cardLeft(tester), closeTo(rest + 80, 0.5));
  });

  testWidgets('a fast flick to the left closes an open card', (tester) async {
    await pumpCard(tester);
    final rest = cardLeft(tester);
    await tester.drag(find.text('Groceries'), const Offset(100, 0));
    await tester.pumpAndSettle();
    // About 30 px of movement after the drag starts: by distance alone the
    // card would stay open, so only the speed can close it.
    await tester.fling(find.text('Groceries'), const Offset(-50, 0), 1500);
    await tester.pumpAndSettle();
    expect(cardLeft(tester), rest);
  });

  testWidgets('a fast flick to the right opens the card', (tester) async {
    await pumpCard(tester);
    final rest = cardLeft(tester);
    // About 30 px of movement after the drag starts: by distance alone the
    // card would snap closed, so only the speed can open it.
    await tester.fling(find.text('Groceries'), const Offset(50, 0), 1500);
    await tester.pumpAndSettle();
    expect(cardLeft(tester), closeTo(rest + 80, 0.5));
  });

  testWidgets('tapping an open card closes it without calling onTap', (
    tester,
  ) async {
    await pumpCard(tester);
    final rest = cardLeft(tester);
    await tester.drag(find.text('Groceries'), const Offset(100, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    expect(taps, 0);
    expect(cardLeft(tester), rest);
  });

  testWidgets('the revealed star toggles the favorite and closes the card', (
    tester,
  ) async {
    await pumpCard(tester);
    final rest = cardLeft(tester);
    await tester.drag(find.text('Groceries'), const Offset(100, 0));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(IconButton),
        matching: find.byIcon(Icons.star_border),
      ),
    );
    await tester.pumpAndSettle();
    expect(favoriteToggles, 1);
    expect(cardLeft(tester), rest);
  });

  testWidgets(
    'dragging past the middle asks to delete; a refusal slides back',
    (tester) async {
      await pumpCard(tester);
      final rest = cardLeft(tester);
      await tester.drag(find.text('Groceries'), const Offset(260, 0));
      await tester.pumpAndSettle();
      expect(deleteRequests, 1);
      expect(cardLeft(tester), rest);
    },
  );

  testWidgets('a confirmed delete leaves the card off screen', (tester) async {
    confirmDelete = true;
    await pumpCard(tester);
    final rest = cardLeft(tester);
    await tester.drag(find.text('Groceries'), const Offset(260, 0));
    await tester.pumpAndSettle();
    expect(deleteRequests, 1);
    expect(cardLeft(tester), greaterThan(rest + 300));
  });

  testWidgets('showHint slides the card a little and back once', (
    tester,
  ) async {
    await pumpCard(tester, showHint: true);
    final rest = cardLeft(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(cardLeft(tester), greaterThan(rest));
    await tester.pumpAndSettle();
    expect(cardLeft(tester), rest);
  });
}
