import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';

//ทำเผื่อ ยังไม่ได้เอาไปใช้
class StudentCourseProgress {
  final Course course;
  final int completedModules;

  const StudentCourseProgress({
    required this.course,
    required this.completedModules,
  });

  bool get isCompleted => completedModules >= course.modules;
}
