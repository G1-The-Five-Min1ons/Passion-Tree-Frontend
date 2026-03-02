import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/more_icon.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album_base_card.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/action_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/edit_album_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';

class PixelAlbumCover extends StatelessWidget {
  final String albumId;
  final double? size;
  final double pixelSize;
  final Color? color;
  final String? imageUrl;
  final String? title;
  final String? subtitle;

  const PixelAlbumCover({
    super.key,
    required this.albumId,
    this.size,
    this.pixelSize = 3.0,
    this.color,
    this.imageUrl,
    this.title,
    this.subtitle
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;

    return PixelBaseCard(
      size: size,
      pixelSize: pixelSize,
      color: primaryColor,
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
            EditAlbumPopup.show(
              context,
              albumId: albumId,
              initialValue: title ?? '',
              imageUrl: imageUrl,
            );
          },
          onDelete: () {
            Navigator.pop(context);
            context.read<AlbumBloc>().add(DeleteAlbumEvent(albumId));
          },
        );
      },
    ),
      topContent: _buildImageWidget(imageUrl, primaryColor),
    );
  }

  Widget _buildImageWidget(String? imageUrl, Color primaryColor) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(color: primaryColor.withValues(alpha: 0.3));
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        cacheWidth: 400,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: primaryColor.withValues(alpha: 0.3),
            child: const Icon(Icons.broken_image, size: 40),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: primaryColor.withValues(alpha: 0.3),
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        cacheWidth: 400,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: primaryColor.withValues(alpha: 0.3),
            child: const Icon(Icons.broken_image, size: 40),
          );
        },
      );
    }

    return Container(
      color: primaryColor.withValues(alpha: 0.3),
      child: const Icon(Icons.image_not_supported, size: 40),
    );
  }
}
