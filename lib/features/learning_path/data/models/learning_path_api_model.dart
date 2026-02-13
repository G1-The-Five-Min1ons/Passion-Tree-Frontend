class LearningPathApiModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final int students;
  final int modules;
  final double rating;
  final String coverImgUrl;
  final String publishStatus;

  LearningPathApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.students,
    required this.modules,
    required this.rating,
    required this.coverImgUrl,
    required this.publishStatus,
  });
  
  //รับทั้ง Get All Learning Paths และ Get Learning Path Detail
  factory LearningPathApiModel.fromJson(Map<String, dynamic> json) {
    return LearningPathApiModel(
      id: json['PathID'] ?? json['path_id'] ?? '',
      title: json['Title'] ?? json['title'] ?? '',
      description: json['Description'] ?? json['description'] ?? '',
      instructor: json['Instructor'] ?? json['instructor'] ?? '',
      students: json['Students'] ?? json['student'] ?? 0,
      modules: json['Modules'] ?? json['modules'] ?? 0,
      rating: (json['Rating'] ?? json['avg_rating'] ?? 0).toDouble(),
      coverImgUrl: json['CoverImgURL'] ?? json['cover_img_url'] ?? '',
      publishStatus: json['PublishStatus'] ?? json['publish_status'] ?? '',
      
    );
  }

}
