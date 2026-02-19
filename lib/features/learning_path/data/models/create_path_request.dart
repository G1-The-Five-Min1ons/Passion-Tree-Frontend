class CreatePathRequest {
  final String title;
  final String objective;
  final String description;
  final String creatorId;
  final String? coverImgUrl;
  final String publishStatus;

  CreatePathRequest({
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
}