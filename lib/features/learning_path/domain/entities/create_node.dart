import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_question_with_choices.dart';

class CreateNode {
  final String title;
  final String description;
  final String pathId;
  final String sequence;
  final String linkvdo;
  final List<CreateMaterial>? materials;
  final List<CreateQuestionWithChoices>? questions;

  const CreateNode({
    required this.title,
    this.description = '',
    required this.pathId,
    required this.sequence,
    this.linkvdo = '',
    this.materials,
    this.questions,
  });
}
