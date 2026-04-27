import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/utils/date_time_formatter.dart';

class TreeMapper {
  static String? _formatResumeDate(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    final localDate = dateTime.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    return '$day/$month/$year';
  }

  static String? _formatServerDate(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day/$month/$year';
  }

  static AlbumItem toAlbumItem(TreeApiModel tree) {
    final chapters =
        tree.nodes
            ?.map(
              (node) => Chapter(
                treeNodeId: node.treeNodeId,
                name: node.nodeTitle,
                isEnrolled: node.nodeScore != null,
                status: node.status,
                complete: node.complete,
                sequence: node.sequence,
                reflectionId: node.reflectionId,
                isStandalone: node.isStandalone,
              ),
            )
            .toList() ??
        [];

    // Sort chapters by sequence
    chapters.sort((a, b) => a.sequence.compareTo(b.sequence));

    return AlbumItem(
      treeId: tree.treeId,
      subjectName: tree.title,
      lastEdited: 'Edited ${DateTimeFormatter.getRelativeTime(tree.lastUpdate)}',
      status: tree.status,
      isReflectionClosed: tree.isReflectionClosed,
      chapters: chapters,
      overallStatus: tree.status,
      treeScore: tree.treeScore,
      isPaused: tree.isPause,
      pauseFrom: _formatServerDate(tree.pauseFrom),
      pauseTo: _formatServerDate(tree.pauseTo),
      resumeOn: _formatResumeDate(tree.pausedAt),
      pathId: tree.pathId,
    );
  }

  static List<AlbumItem> toAlbumItemList(List<TreeApiModel> trees) {
    return trees.map((tree) => toAlbumItem(tree)).toList();
  }

  /// Extract unique learning path IDs from trees
  static List<String> extractUniqueLearningPathIds(List<TreeApiModel> trees) {
    final pathIds = trees.map((tree) => tree.pathId).toSet();
    return pathIds.toList();
  }
}
