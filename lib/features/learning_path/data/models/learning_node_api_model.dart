class LearningNodeApiModel {
  final String nodeId;
  final String title;
  final String description;
  final int sequence;
  final String pathId;
  final String status;
  final String complete;
  final String? linkVdo;

  LearningNodeApiModel({
    required this.nodeId,
    required this.title,
    required this.description,
    required this.sequence,
    required this.pathId,
    required this.status,
    required this.complete,
    this.linkVdo,
  });

  factory LearningNodeApiModel.fromJson(Map<String, dynamic> json) {
    return LearningNodeApiModel(
      nodeId: json['node_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sequence: json['sequence'] ?? 0,
      pathId: json['path_id'] ?? '',
      status: json['status'] ?? 'locked',
      complete: (json['complete'] == null || json['complete'] == 'null') ? 'false' : json['complete'].toString(),
      linkVdo: (json['link_vdo'] == null || json['link_vdo'] == 'null') ? null : json['link_vdo']?.toString(),
    );
  }
}
