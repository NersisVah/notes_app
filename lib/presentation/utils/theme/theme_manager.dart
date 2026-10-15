import 'package:flutter/material.dart';

import '../../resources/app_colors.dart';
import '../../resources/app_font_sizes.dart';
import '../../resources/app_sizes.dart';

class ThemeManager {
  ThemeManager._();

  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: AppColors.primary,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: _colorScheme(),
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      appBarTheme: _appBarTheme(),
      floatingActionButtonTheme: _floatingActionButtonTheme(),
      iconButtonTheme: _iconButtonTheme(),
      dialogTheme: _dialogTheme(),
      bottomSheetTheme: _bottomSheetTheme(),
      textSelectionTheme: _textSelectionTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      textTheme: _textTheme(),
    );
  }

  static ColorScheme _colorScheme() {
    return const ColorScheme.dark(
      primary: AppColors.primary,
      error: AppColors.red,
    );
  }

  static AppBarTheme _appBarTheme() {
    return const AppBarTheme(
      backgroundColor: AppColors.scaffoldBackground,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      actionsPadding: EdgeInsets.only(right: AppSizes.paddingLarge),
    );
  }

  static FloatingActionButtonThemeData _floatingActionButtonTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      iconSize: AppSizes.floatingActionButtonIconSize,
      shape: CircleBorder(),
    );
  }

  static IconButtonThemeData _iconButtonTheme() {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
      ),
    );
  }

  static DialogThemeData _dialogTheme() {
    return DialogThemeData(
      backgroundColor: AppColors.scaffoldBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
    );
  }

  static BottomSheetThemeData _bottomSheetTheme() {
    return const BottomSheetThemeData(
      backgroundColor: AppColors.secondaryBackground,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
    );
  }

  static TextSelectionThemeData _textSelectionTheme() {
    return const TextSelectionThemeData(cursorColor: AppColors.primary);
  }

  static InputDecorationTheme _inputDecorationTheme() {
    return InputDecorationTheme(
      labelStyle: const TextStyle(color: AppColors.grey),
      floatingLabelStyle: const TextStyle(color: AppColors.grey),
      enabledBorder: _inputBorder(
        AppColors.secondaryBackground,
        AppSizes.borderWidth,
      ),
      focusedBorder: _inputBorder(
        AppColors.secondaryBackground,
        AppSizes.borderWidthFocused,
      ),
      errorBorder: _inputBorder(AppColors.red, AppSizes.borderWidth),
      focusedErrorBorder: _inputBorder(
        AppColors.red,
        AppSizes.borderWidthFocused,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme() {
    return const TextTheme(
      titleLarge: TextStyle(fontSize: AppFontSizes.large),
      titleMedium: TextStyle(fontSize: AppFontSizes.medium),
      bodyMedium: TextStyle(fontSize: AppFontSizes.small),
    );
  }
}
