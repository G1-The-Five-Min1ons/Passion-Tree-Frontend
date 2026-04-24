import 'package:passion_tree_frontend/features/learning_path/data/models/material_api_model.dart';

class LearningNodeApiModel {
  final String nodeId;
  final String title;
  final String description;
  final int sequence;
  final String pathId;
  final List<MaterialApiModel> materials;
  final String status;
  final String complete;
  final String? linkVdo;

  LearningNodeApiModel({
    required this.nodeId,
    required this.title,
    required this.description,
    required this.sequence,
    required this.pathId,
    this.materials = const [],
    required this.status,
    required this.complete,
    this.linkVdo,
  });

  factory LearningNodeApiModel.fromJson(Map<String, dynamic> json) {
    final rawMaterials = json['materials'] ?? json['material'];
    final materialModels = (rawMaterials as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(MaterialApiModel.fromJson)
            .toList() ??
        [];

    // Some backends may return a single PDF URL field instead of materials list.
    final fallbackPdfUrl =
        (json['pdf'] ?? json['pdf_url'] ?? json['pdfUrl'])?.toString();
    final normalizedMaterials =
        materialModels.isNotEmpty || fallbackPdfUrl == null || fallbackPdfUrl.isEmpty
        ? materialModels
        : [
            MaterialApiModel(
              materialId: '',
              type: 'file',
              url: fallbackPdfUrl,
              nodeId: json['node_id']?.toString() ?? '',
            ),
          ];

    return LearningNodeApiModel(
      nodeId: json['node_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sequence: json['sequence'] ?? 0,
      pathId: json['path_id'] ?? '',
      materials: normalizedMaterials,
      status: json['status'] ?? 'locked',
      complete: (json['complete'] == null || json['complete'] == 'null') ? 'false' : json['complete'].toString(),
      linkVdo: (json['link_vdo'] == null || json['link_vdo'] == 'null') ? null : json['link_vdo']?.toString(),
    );
  }
}
