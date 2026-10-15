import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../resources/app_colors.dart';
import '../../../resources/app_sizes.dart';
import '../../../utils/router/app_routes.dart';
import '../../../widgets/styled_text.dart';

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: AppSizes.paddingLarge),
          child: StyledText('Notes', size: AppTextSize.large),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            // TODO: show the "how to use" bottom sheet
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.note),
        child: const Icon(
          Icons.add,
          shadows: [
            Shadow(
              color: AppColors.shadow,
              blurRadius: AppSizes.shadowBlurRadius,
            ),
          ],
        ),
      ),
    );
  }
}
