import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class Album {
  final String title;
  final String subtitle;
  final String image;
  final List<AlbumItem>? items;

  Album({
    required this.title,
    required this.subtitle,
    required this.image,
    this.items,
  });
}

class AlbumItem {
  final String subjectName;
  final String lastEdited;
  final String status;

  AlbumItem({
    required this.subjectName,
    required this.lastEdited,
    required this.status,
  });

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'died':
        return AppColors.textPrimary;
      case 'fading':
        return AppColors.warning;
      case 'dying':
        return AppColors.cancel;
      case 'growing':
      default:
        return AppColors.status;
    }
  }
}