import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/presentation/resources/app_colors.dart';
import 'package:notes_app/presentation/utils/theme/theme_manager.dart';
import 'package:notes_app/presentation/widgets/confirmation_dialog_view.dart';

void main() {
  late bool? result;

  Future<void> openDialog(WidgetTester tester, {bool isDelete = false}) async {
    result = null;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeManager.getTheme(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await ConfirmationDialogView.show(
              context,
              message: 'Are you sure?',
              confirmLabel: 'Yes',
              isDelete: isDelete,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Color buttonColor(WidgetTester tester, String label) {
    final button = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(ElevatedButton),
      ),
    );
    return button.style!.backgroundColor!.resolve({})!;
  }

  testWidgets('confirm returns true and closes', (tester) async {
    await openDialog(tester);
    expect(find.text('Are you sure?'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(find.text('Are you sure?'), findsNothing);
  });

  testWidgets('cancel returns false', (tester) async {
    await openDialog(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('tapping outside returns false', (tester) async {
    await openDialog(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('confirm is red for deletes and primary otherwise', (
    tester,
  ) async {
    await openDialog(tester, isDelete: true);
    expect(buttonColor(tester, 'Yes'), AppColors.red);
    expect(buttonColor(tester, 'Cancel'), AppColors.secondaryBackground);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await openDialog(tester);
    expect(buttonColor(tester, 'Yes'), AppColors.primary);
  });
}
