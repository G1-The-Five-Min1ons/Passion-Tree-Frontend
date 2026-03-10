import 'package:passion_tree_frontend/features/learning_path/domain/entities/generated_node.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/generated_node_api_model.dart';

extension GeneratedNodeMapper on GeneratedNodeApiModel {
  GeneratedNode toEntity() {
    return GeneratedNode(
      sequence: sequence,
      title: title,
    );
  }
}
