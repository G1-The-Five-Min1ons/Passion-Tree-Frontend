class MaterialApiModel {
  final String materialId;
  final String type;
  final String url;
  final String nodeId;

  const MaterialApiModel({
    required this.materialId,
    required this.type,
    required this.url,
    required this.nodeId,
  });

  factory MaterialApiModel.fromJson(Map<String, dynamic> json) {
    return MaterialApiModel(
      materialId: json['material_id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      nodeId: json['node_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'type': type,
      'url': url,
      'node_id': nodeId,
    };
  }
}
