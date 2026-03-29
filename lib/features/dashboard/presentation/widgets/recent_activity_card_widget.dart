import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

class RecentActivityCardWidget extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivityCardWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: PixelBorderContainer(
          pixelSize: 3,
          padding: const EdgeInsets.all(12),
          child: Text(
            'No recent activity',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return PixelBorderContainer(
      pixelSize: 3,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: activities
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
                            item.title,
                            style: AppTypography.bodySemiBold.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            item.timeAgo,
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
                        item.typeLabel,
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
