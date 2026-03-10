import 'package:passion_tree_frontend/features/learning_path/domain/entities/ai_generate_response.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/ai_generate_response_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/generated_node_mapper.dart';

extension AIGenerateResponseMapper on AIGenerateResponseApiModel {
  AIGenerateResponse toEntity() {
    return AIGenerateResponse(
      topic: topic,
      nodes: nodes.map((node) => node.toEntity()).toList(),
    );
  }
}
