import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_node.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_node_request_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/create_material_mapper.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mappers/create_question_with_choices_mapper.dart';

extension CreateNodeMapper on CreateNode {
  CreateNodeRequestApiModel toApiModel() {
    return CreateNodeRequestApiModel(
      title: title,
      description: description,
      pathId: pathId,
      sequence: sequence,
      linkvdo: linkvdo,
      materials: materials?.map((m) => m.toApiModel()).toList(),
      questions: questions?.map((q) => q.toApiModel()).toList(),
    );
  }
}

extension CreateNodeRequestApiModelMapper on CreateNodeRequestApiModel {
  CreateNode toEntity() {
    return CreateNode(
      title: title,
      description: description,
      pathId: pathId,
      sequence: sequence,
      linkvdo: linkvdo,
      materials: materials?.map((m) => m.toEntity()).toList(),
      questions: questions?.map((q) => q.toEntity()).toList(),
    );
  }
}
