import 'package:flutter/material.dart';

import '../resources/app_sizes.dart';
import 'styled_text.dart';

/// Read-only note title and body.
class NoteContentView extends StatelessWidget {
  const NoteContentView({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StyledText(title, size: AppTextSize.large),
          const SizedBox(height: AppSizes.paddingMedium),
          StyledText(body, size: AppTextSize.small),
        ],
      ),
    );
  }
}
