import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/utils/date_time_formatter.dart';

class TreeMapper {
  static AlbumItem toAlbumItem(TreeApiModel tree) {
    final chapters = tree.nodes?.map((node) => Chapter(
      treeNodeId: node.treeNodeId,
      name: node.nodeTitle,
      isEnrolled: node.nodeScore != null,
      status: node.status,
      complete: node.complete,
      sequence: node.sequence,
      reflectionId: node.reflectionId,
    )).toList() ?? [];

    // Sort chapters by sequence
    chapters.sort((a, b) => a.sequence.compareTo(b.sequence));

    return AlbumItem(
      treeId: tree.treeId,
      subjectName: tree.title,
      lastEdited: 'Edited ${DateTimeFormatter.getRelativeTime(tree.lastUpdate)}',
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



  /// Extract unique learning path IDs from trees
  static List<String> extractUniqueLearningPathIds(List<TreeApiModel> trees) {
    final pathIds = trees.map((tree) => tree.pathId).toSet();
    return pathIds.toList();
  }
}
