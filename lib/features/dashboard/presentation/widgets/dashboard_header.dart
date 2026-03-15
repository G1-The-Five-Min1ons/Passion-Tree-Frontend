import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/icons/tree_icon.png', width: 46, height: 46),
        const SizedBox(width: 8),
        Text(
          'Dashboard&Profile',
          style: AppPixelTypography.smallTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
