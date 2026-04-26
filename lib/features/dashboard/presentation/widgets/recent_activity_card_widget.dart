import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

class RecentActivityCardWidget extends StatefulWidget {
  final List<ActivityItem> activities;
  final ValueChanged<ActivityItem>? onActivityTap;

  /// Maximum items to show before "Show more" button
  static const int _initialLimit = 5;

  const RecentActivityCardWidget({
    super.key,
    required this.activities,
    this.onActivityTap,
  });

  @override
  State<RecentActivityCardWidget> createState() =>
      _RecentActivityCardWidgetState();
}

class _RecentActivityCardWidgetState extends State<RecentActivityCardWidget> {
  bool _isExpanded = false;

  Color _badgeColor(ActivityItem item) {
    switch (item.activityType) {
      case 'complete_node':
        return AppColors.status.withOpacity(0.75);
      case 'enroll_path':
        return AppColors.warning.withOpacity(0.75);
      default:
        return AppColors.primaryBrand;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activities.isEmpty) {
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

    final displayItems = _isExpanded
        ? widget.activities
        : widget.activities.take(RecentActivityCardWidget._initialLimit).toList();

    final hasMore =
        widget.activities.length > RecentActivityCardWidget._initialLimit;

    return PixelBorderContainer(
      pixelSize: 3,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ...displayItems.map(
            (item) => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onActivityTap == null
                    ? null
                    : () => widget.onActivityTap!(item),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                        constraints: const BoxConstraints(minWidth: 84),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        alignment: Alignment.center,
                        color: _badgeColor(item),
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
              ),
            ),
          ),

          // Show more / Show less toggle
          if (hasMore)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpanded ? 'Show less' : 'Show more',
                      style: AppTypography.smallBodySemiBold.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
