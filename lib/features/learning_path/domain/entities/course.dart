enum CourseStatus { inProgress, completed }

class Course {
  final String title;
  final String description;
  final String instructor;
  final int students;
  final int modules;
  final String imageAsset;
  final double rating;
  final String category;
  final CourseStatus status;


  const Course({
    required this.title,
    required this.description,
    required this.instructor,
    required this.students,
    required this.modules,
    required this.imageAsset,
    required this.rating,
    required this.category,
    required this.status,
  });
}

