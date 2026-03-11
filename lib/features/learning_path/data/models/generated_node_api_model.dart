class GeneratedNodeApiModel {
  final int sequence;
  final String title;

  GeneratedNodeApiModel({
    required this.sequence,
    required this.title,
  });

  factory GeneratedNodeApiModel.fromJson(Map<String, dynamic> json) {
    return GeneratedNodeApiModel(
      sequence: json['sequence'] ?? 0,
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sequence': sequence,
      'title': title,
    };
  }
}
