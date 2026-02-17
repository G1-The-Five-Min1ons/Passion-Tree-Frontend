import 'package:passion_tree_frontend/features/learning_path/data/models/material_api_model.dart';

class NodeDetailApiModel {
  final String nodeId;
  final String title;
  final String description;
  final int sequence;
  final String pathId;
  final List<MaterialApiModel> materials;
  final String status;
  final String complete;

  const NodeDetailApiModel({
    required this.nodeId,
    required this.title,
    required this.description,
    required this.sequence,
    required this.pathId,
    required this.materials,
    required this.status,
    required this.complete,
  });

  factory NodeDetailApiModel.fromJson(Map<String, dynamic> json) {
    return NodeDetailApiModel(
      nodeId: json['node_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      sequence: json['sequence'] as int,
      pathId: json['path_id'] as String,
      materials: (json['materials'] as List<dynamic>?)
              ?.map((m) => MaterialApiModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] ?? 'locked',
      complete: json['complete'] ?? 'false',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'node_id': nodeId,
      'title': title,
      'description': description,
      'sequence': sequence,
      'path_id': pathId,
      'materials': materials.map((m) => m.toJson()).toList(),
      'status': status,
      'complete': complete,
    };
  }
}
