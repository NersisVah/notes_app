import 'package:flutter/material.dart';

import '../resources/app_colors.dart';
import '../resources/app_sizes.dart';
import 'styled_text.dart';

/// Yes/no dialog for saving, deleting or leaving without saving.
///
/// Use [show], which resolves to `true` only when the user confirms.
class ConfirmationDialogView extends StatelessWidget {
  const ConfirmationDialogView({
    super.key,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String message;
  final String confirmLabel;
  final String cancelLabel;

  static Future<bool> show(
    BuildContext context, {
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialogView(
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info,
              size: AppSizes.dialogIconSize,
              color: AppColors.secondaryBackground,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            StyledText(
              message,
              size: AppTextSize.small,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: cancelLabel,
                    color: AppColors.red,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: _DialogButton(
                    label: confirmLabel,
                    color: AppColors.green,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      onPressed: onPressed,
      child: StyledText(label, size: AppTextSize.small, color: AppColors.white),
    );
  }
}
