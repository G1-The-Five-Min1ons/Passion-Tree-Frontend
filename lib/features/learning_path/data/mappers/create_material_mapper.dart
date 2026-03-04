import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_material_request_api_model.dart';

extension CreateMaterialMapper on CreateMaterial {
  CreateMaterialRequestApiModel toApiModel() {
    return CreateMaterialRequestApiModel(
      type: type,
      url: url,
    );
  }
}

extension CreateMaterialRequestApiModelMapper on CreateMaterialRequestApiModel {
  CreateMaterial toEntity() {
    return CreateMaterial(
      type: type,
      url: url,
    );
  }
}
