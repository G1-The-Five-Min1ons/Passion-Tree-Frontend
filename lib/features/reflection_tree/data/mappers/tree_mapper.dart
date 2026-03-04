import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';

class TreeMapper {
  static AlbumItem toAlbumItem(TreeApiModel tree) {
    final chapters = tree.nodes?.map((node) => Chapter(
      name: node.nodeTitle,
      isEnrolled: node.nodeScore != null,
    )).toList() ?? [];

    return AlbumItem(
      treeId: tree.treeId,
      subjectName: tree.title,
      lastEdited: 'Edited ${_formatLastEdited(tree.lastUpdate)}',
      status: tree.status,
      chapters: chapters,
      overallStatus: tree.isPause ? 'paused' : tree.status,
      resumeOn: null,
      pathId: tree.pathId,
    );
  }

  static List<AlbumItem> toAlbumItemList(List<TreeApiModel> trees) {
    return trees.map((tree) => toAlbumItem(tree)).toList();
  }

  static String _formatLastEdited(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Extract unique learning path IDs from trees
  static List<String> extractUniqueLearningPathIds(List<TreeApiModel> trees) {
    final pathIds = trees.map((tree) => tree.pathId).toSet();
    return pathIds.toList();
  }
}
