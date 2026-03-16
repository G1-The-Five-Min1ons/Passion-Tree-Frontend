import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class Album {
  final String albumId;
  final String title;
  final String subtitle;
  final String image;
  final List<AlbumItem>? items;

  Album({
    required this.albumId,
    required this.title,
    required this.subtitle,
    required this.image,
    this.items,
  });
}

class AlbumItem {
  final String? treeId;
  final String subjectName;
  final String lastEdited;
  final String status;
  final List<Chapter> chapters;
  final String overallStatus;
  final String? resumeOn;
  final String? pathId;

  AlbumItem({
    this.treeId,
    required this.subjectName,
    required this.lastEdited,
    required this.status,
    this.chapters = const [],
    required this.overallStatus,
    this.resumeOn,
    this.pathId,
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

class Chapter {
  final String treeNodeId;
  final String name;
  final bool isEnrolled;
  final String? status;
  final String? complete;
  final int sequence;
  final String? reflectionId;
  final bool isStandalone;

  Chapter({
    required this.treeNodeId,
    required this.name,
    this.isEnrolled = false,
    this.status,
    this.complete,
    this.sequence = 0,
    this.reflectionId,
    this.isStandalone = false,
  });

  // Helper to check if node is completed
  bool get isCompleted => complete == 'true';
  
  // Helper to check if node has reflection
  bool get hasReflection => reflectionId != null && reflectionId!.isNotEmpty;

  // Helper to check if node can be reflected (completed LP node or standalone reflection node)
  bool get canReflect => isCompleted || isStandalone;
}
