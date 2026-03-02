import 'package:passion_tree_frontend/features/learning_path/data/models/material_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/material.dart';

extension MaterialMapper on MaterialApiModel {
  Material toEntity() {
    return Material(
      materialId: materialId,
      type: type,
      url: url,
      nodeId: nodeId,
    );
  }
}
