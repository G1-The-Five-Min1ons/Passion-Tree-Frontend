class LearningNodeApiModel {
  final String nodeId;
  final String title;
  final String description;
  final int sequence;
  final String pathId;
  final String status;
  final String complete;

  LearningNodeApiModel({
    required this.nodeId,
    required this.title,
    required this.description,
    required this.sequence,
    required this.pathId,
    required this.status,
    required this.complete,
  });

  factory LearningNodeApiModel.fromJson(Map<String, dynamic> json) {
    return LearningNodeApiModel(
      nodeId: json['node_id'],
      title: json['title'],
      description: json['description'],
      sequence: json['sequence'],
      pathId: json['path_id'],
      status: json['status'] ?? 'locked',
      complete: json['complete'] ?? 'false',
    );
  }
}
