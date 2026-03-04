import 'package:passion_tree_frontend/features/learning_path/domain/entities/generated_node.dart';

class AIGenerateResponse {
  final String topic;
  final List<GeneratedNode> nodes;

  const AIGenerateResponse({
    required this.topic,
    required this.nodes,
  });
}
