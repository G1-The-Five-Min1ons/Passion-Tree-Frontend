import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/more_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album_base_card.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/main_tree_image.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/action_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/edit_tree_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/resume_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';


class TreeAlbumCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final Widget dataDisplay;
  final String treeStatus;
  final String currentAlbumname;
  final List<String> albumOptions;
  final List<Album> availableAlbums;
  final String treeId;
  final String albumId;
  final VoidCallback? onStatusTap;
  final VoidCallback? onCardTap;
  final VoidCallback? onDelete;
  final String? resumeOn;

  const TreeAlbumCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.dataDisplay,
    required this.treeStatus,
    required this.currentAlbumname,
    required this.albumOptions,
    required this.availableAlbums,
    required this.treeId,
    required this.albumId,
    this.onStatusTap,
    this.onCardTap,
    this.onDelete,
    this.resumeOn,
  });

  @override
  Widget build(BuildContext context) {
    bool isPaused = resumeOn != null;
    return Stack(
      children: [
        GestureDetector(
        onTap: isPaused ? null : onCardTap,
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
                  pathOptions: albumOptions.isEmpty 
                      ? ['No albums available'] 
                      : albumOptions,
                  onSave: (newTitle, selectedAlbumName) {
                    String? newAlbumId;
                    if (selectedAlbumName != currentAlbumname && availableAlbums.isNotEmpty) {
                      try {
                        final selectedAlbum = availableAlbums.firstWhere(
                          (album) => album.title == selectedAlbumName,
                        );
                        newAlbumId = selectedAlbum.albumId;
                      } catch (e) {
                        // If not found, don't change album
                        newAlbumId = null;
                      }
                    }
                    
                    context.read<AlbumBloc>().add(
                      UpdateTreeEvent(
                        treeId: treeId,
                        albumId: albumId,
                        title: newTitle,
                        newAlbumId: newAlbumId,
                      ),
                    );
                  },
                );
              },
              onDelete: () {
                onDelete?.call();
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
                  ),
                ),
              ),
            ),
          ),
        ),

        if (resumeOn != null)
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              ResumePopup.show(context);
            },
            child: Container(
            decoration: BoxDecoration(
              color: AppColors.textDisabled.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Paused",
                  style: AppPixelTypography.smallTitle.copyWith(color: AppColors.surface),
                ),
                const SizedBox(height: 2),
                Text(
                  "Resume on : $resumeOn",
                  style: AppTypography.smallBodyRegular.copyWith(color: AppColors.surface),
                ),
              ],
            ),
          ),
          ),
        ),
      ],
    );
  }
}