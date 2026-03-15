import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';

class RecentActivityCardWidget extends StatelessWidget {
  const RecentActivityCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Complete React fundamentals', 'Learning', '2 Hours ago'),
      ('Started photography module', 'Learning', '2 Days ago'),
      ('Completed weekly mission', 'Mission', '1 Days ago'),
      ('14-Day streak achieved', 'Milestone', '3 Days ago'),
    ];

    return PixelBorderContainer(
      pixelSize: 3,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: items
            .map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: AppTypography.bodySemiBold.copyWith(
                              color: AppColors.primaryBrand,
                            ),
                          ),
                          Text(
                            item.$3,
                            style: AppTypography.smallBodyRegular.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      color: AppColors.primaryBrand,
                      child: Text(
                        item.$2,
                        style: AppTypography.smallBodySemiBold.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
