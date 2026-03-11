class CreateMaterialRequestApiModel {
  final String type;
  final String url;

  CreateMaterialRequestApiModel({
    required this.type,
    required this.url,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
  };

  factory CreateMaterialRequestApiModel.fromJson(Map<String, dynamic> json) {
    return CreateMaterialRequestApiModel(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
