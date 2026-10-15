import 'package:flutter/material.dart';

enum AppTextSize { small, medium, large }

class StyledText extends StatelessWidget {
  const StyledText(
    this.text, {
    super.key,
    required this.size,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;
  final AppTextSize size;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final baseStyle = switch (size) {
      AppTextSize.small => textTheme.bodyMedium,
      AppTextSize.medium => textTheme.titleMedium,
      AppTextSize.large => textTheme.titleLarge,
    };

    return Text(
      text,
      style: baseStyle?.copyWith(color: color),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
