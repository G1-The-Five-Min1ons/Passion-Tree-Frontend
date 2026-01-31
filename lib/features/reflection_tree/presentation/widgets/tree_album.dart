import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/more_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album_base_card.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/main_tree_image.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/action_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/edit_tree_popup.dart';

class TreeAlbumCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final Widget dataDisplay;
  final String treeStatus;
  final String currentAlbumname;
  final VoidCallback? onStatusTap;
  final VoidCallback? onCardTap;

  const TreeAlbumCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.dataDisplay,
    required this.treeStatus,
    required this.currentAlbumname,
    this.onStatusTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
      GestureDetector(
      onTap: onCardTap,
      child: PixelBaseCard(
        title: title,
        subtitle: subtitle,
        actionIcon: IconButton(
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        splashRadius: 20,
        icon: const MoreIcon(),
        onPressed: () {
          ActionPopUp.show(
            context,
            onEdit: () {
              EditTreePopUp.show(
                context,
                initialName: title,
                initialPath: currentAlbumname,
                pathOptions: [
                  'Biology 101', //เดี๋ยวค่อยถึงมาจาก db จริง
                  'Genetics',
                  'Microbiology',
                  'Criminal Law',
                ],
              );
            },
            onDelete: () {
              debugPrint("Delete Album: $title");
            },
          );
        },
      ),
        topContent: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.surface,
          child: Stack(
            children: [
              Center(
                child: MainTreeImage(status: treeStatus),
              )
            ],
          ),
        ),
      ),
    ),

      Positioned(
        top: 0,
        right: 0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            onStatusTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: AppPixelTypography.littleSmall.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),),
              ),
            ),
          ),
        )
      ],
    );
  }
}