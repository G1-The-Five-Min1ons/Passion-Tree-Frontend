import 'package:passion_tree_frontend/features/learning_path/data/models/create_material_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_question_with_choices_request_api_model.dart';

class CreateNodeRequestApiModel {
  final String title;
  final String description;
  final String pathId;
  final String sequence;
  final String linkvdo;
  final List<CreateMaterialRequestApiModel>? materials;
  final List<CreateQuestionWithChoicesRequestApiModel>? questions;

  CreateNodeRequestApiModel({
    required this.title,
    this.description = '',
    required this.pathId,
    required this.sequence,
    this.linkvdo = '',
    this.materials,
    this.questions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'path_id': pathId,
      'sequence': sequence,
      'link_vdo': linkvdo,
    };
    
    if (materials != null && materials!.isNotEmpty) {
      data['material'] = materials!.map((v) => v.toJson()).toList();
    }

    if (questions != null && questions!.isNotEmpty) {
      data['Question'] = questions!.map((v) => v.toJson()).toList();
    }

    return data;
  }

  factory CreateNodeRequestApiModel.fromJson(Map<String, dynamic> json) {
    var materialsList = json['material'] as List? ?? [];
    List<CreateMaterialRequestApiModel> materials = 
        materialsList.map((i) => CreateMaterialRequestApiModel.fromJson(i)).toList();

    var questionsList = json['Question'] as List? ?? [];
    List<CreateQuestionWithChoicesRequestApiModel> questions = 
        questionsList.map((i) => CreateQuestionWithChoicesRequestApiModel.fromJson(i)).toList();

    return CreateNodeRequestApiModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pathId: json['path_id'] ?? '',
      sequence: json['sequence'] ?? '',
      linkvdo: json['link_vdo'] ?? '',
      materials: materialsList.isEmpty ? null : materials,
      questions: questionsList.isEmpty ? null : questions,
    );
  }
}
