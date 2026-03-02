import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_node_api_model.dart';

extension LearningNodeMapper on LearningNodeApiModel {
  NodeDetail toEntity() {
    return NodeDetail(
      nodeId: nodeId,
      title: title,
      description: description,
      sequence: sequence,
      pathId: pathId,
      materials: const [],
      status: status,
      complete: complete,
      linkVdo: linkVdo,
    );
  }
}
