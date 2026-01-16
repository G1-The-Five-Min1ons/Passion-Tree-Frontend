import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/more_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album_base_card.dart';

class TreeAlbumCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final Widget dataDisplay;

  const TreeAlbumCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.dataDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return PixelBaseCard(
      title: title,
      subtitle: subtitle,
      actionIcon: const MoreIcon(),
      overlay: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(4)
        ),
        child: Text(
          statusText,
          textAlign: TextAlign.center,
          style: AppPixelTypography.littleSmall.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      topContent: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        child: Center(child: dataDisplay),
      ),
    );
  }
}