import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/more_icon.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album_base_card.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/action_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/edit_album_popup.dart';

class PixelAlbumCover extends StatelessWidget {
  final double? size;
  final double pixelSize;
  final Color? color;
  final String? imageUrl;
  final String? title;
  final String? subtitle;

  const PixelAlbumCover({
    super.key,
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
              initialValue: title ?? '');
          },
          onDelete: () {
            debugPrint("Delete Album: $title");
          },
        );
      },
    ),
      topContent: imageUrl != null
        ? Image.asset(imageUrl!, fit: BoxFit.cover, width: double.infinity) //ถ้าดึงจาก db อาจจะต้องเปลี่ยน asset
        : Container(color: primaryColor.withValues(alpha: 0.3)),
    );
  }
}
