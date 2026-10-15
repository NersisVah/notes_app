import 'package:flutter/material.dart';

import '../../resources/app_colors.dart';
import '../../resources/app_font_sizes.dart';

class ThemeManager {
  ThemeManager._();

  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(primary: AppColors.primary),
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: AppFontSizes.large),
        titleMedium: TextStyle(fontSize: AppFontSizes.medium),
        bodyMedium: TextStyle(fontSize: AppFontSizes.small),
      ),
    );
  }
}
