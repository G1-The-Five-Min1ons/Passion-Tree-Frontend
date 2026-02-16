import 'package:passion_tree_frontend/features/learning_path/data/models/node_detail_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/material_mapper.dart';

extension NodeDetailMapper on NodeDetailApiModel {
  NodeDetail toEntity() {
    return NodeDetail(
      nodeId: nodeId,
      title: title,
      description: description,
      sequence: sequence,
      pathId: pathId,
      materials: materials.map((m) => m.toEntity()).toList(),
    );
  }
}
