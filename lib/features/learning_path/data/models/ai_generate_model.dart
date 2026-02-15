class GeneratedNode {
  final int sequence;
  final String title;

  GeneratedNode({required this.sequence, required this.title});

  factory GeneratedNode.fromJson(Map<String, dynamic> json) {
    return GeneratedNode(
      sequence: json['sequence'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}

class AIGenerateResponse {
  final String topic;
  final List<GeneratedNode> nodes;

  AIGenerateResponse({required this.topic, required this.nodes});

  factory AIGenerateResponse.fromJson(Map<String, dynamic> json) {
    var nodesList = json['nodes'] as List;
    List<GeneratedNode> nodes = nodesList.map((i) => GeneratedNode.fromJson(i)).toList();

    return AIGenerateResponse(
      topic: json['topic'] ?? '',
      nodes: nodes,
    );
  }
}