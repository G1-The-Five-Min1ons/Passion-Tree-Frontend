import 'package:passion_tree_frontend/features/learning_path/data/models/generated_node_api_model.dart';

class AIGenerateResponseApiModel {
  final String topic;
  final List<GeneratedNodeApiModel> nodes;

  AIGenerateResponseApiModel({
    required this.topic,
    required this.nodes,
  });

  factory AIGenerateResponseApiModel.fromJson(Map<String, dynamic> json) {
    var nodesList = json['nodes'] as List? ?? [];
    List<GeneratedNodeApiModel> nodes = 
        nodesList.map((i) => GeneratedNodeApiModel.fromJson(i)).toList();

    return AIGenerateResponseApiModel(
      topic: json['topic'] ?? '',
      nodes: nodes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'nodes': nodes.map((node) => node.toJson()).toList(),
    };
  }
}
