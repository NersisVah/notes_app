import 'package:flutter/material.dart';

import '../resources/app_colors.dart';
import '../resources/app_sizes.dart';
import 'styled_text.dart';

/// Yes/no dialog for saving, deleting or leaving without saving.
///
/// Use [show], which resolves to `true` only when the user confirms. The
/// confirm button is red when [isDelete] is true, primary otherwise.
class ConfirmationDialogView extends StatelessWidget {
  const ConfirmationDialogView({
    super.key,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDelete,
  });

  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDelete;

  static Future<bool> show(
    BuildContext context, {
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    bool isDelete = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialogView(
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDelete: isDelete,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // Scrolls only when the content is taller than the screen, for example
      // with a large system font.
      child: SingleChildScrollView(
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
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: cancelLabel,
                    color: AppColors.secondaryBackground,
                    labelColor: AppColors.white,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: _DialogButton(
                    label: confirmLabel,
                    color: isDelete ? AppColors.red : AppColors.primary,
                    labelColor: isDelete
                        ? AppColors.white
                        : AppColors.scaffoldBackground,
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
    required this.labelColor,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final Color labelColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: labelColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      onPressed: onPressed,
      child: StyledText(
        label,
        size: AppTextSize.small,
        color: labelColor,
        textAlign: TextAlign.center,
      ),
    );
  }
}
