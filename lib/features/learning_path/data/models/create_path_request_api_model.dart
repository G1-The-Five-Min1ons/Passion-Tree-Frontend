class CreatePathRequestApiModel {
  final String title;
  final String objective;
  final String description;
  final String creatorId;
  final String? coverImgUrl;
  final String publishStatus;

  CreatePathRequestApiModel({
    required this.title,
    required this.objective,
    required this.description,
    required this.creatorId,
    this.coverImgUrl,
    this.publishStatus = 'draft',
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'objective': objective,
    'description': description,
    'creator_id': creatorId,
    'cover_img_url': coverImgUrl ?? '',
    'publish_status': publishStatus,
  };

  factory CreatePathRequestApiModel.fromJson(Map<String, dynamic> json) {
    return CreatePathRequestApiModel(
      title: json['title'] ?? '',
      objective: json['objective'] ?? '',
      description: json['description'] ?? '',
      creatorId: json['creator_id'] ?? '',
      coverImgUrl: json['cover_img_url'],
      publishStatus: json['publish_status'] ?? 'draft',
    );
  }
}
