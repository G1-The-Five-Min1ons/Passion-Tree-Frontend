import 'package:passion_tree_frontend/features/learning_path/domain/entities/material.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/quiz_question.dart';

class NodeDetail {
  final String nodeId;
  final String title;
  final String description;
  final int sequence;
  final String pathId;
  final List<Material> materials;
  final List<QuizQuestion> questions;
  final String status;
  final String complete;
  final String? linkVdo;

  const NodeDetail({
    required this.nodeId,
    required this.title,
    required this.description,
    required this.sequence,
    required this.pathId,
    required this.materials,
    this.questions = const [],
    required this.status,
    required this.complete,
    this.linkVdo,
  });
}
