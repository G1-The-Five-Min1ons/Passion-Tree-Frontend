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
  final String? linkVdo;

  const NodeDetailApiModel({
    required this.nodeId,
    required this.title,
    required this.description,
    required this.sequence,
    required this.pathId,
    required this.materials,
    required this.status,
    required this.complete,
    this.linkVdo,
  });

  factory NodeDetailApiModel.fromJson(Map<String, dynamic> json) {
    return NodeDetailApiModel(
      nodeId: json['node_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sequence: json['sequence'] ?? 0,
      pathId: json['path_id']?.toString() ?? '',
      materials: (json['materials'] as List<dynamic>?)
              ?.map((m) => MaterialApiModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status']?.toString() ?? 'locked',
      complete: (json['complete'] == null || json['complete'] == 'null') ? 'false' : json['complete'].toString(),
      linkVdo: (json['link_vdo'] == null || json['link_vdo'] == 'null') ? null : json['link_vdo']?.toString(),
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
      'link_vdo': linkVdo,
    };
  }
}
