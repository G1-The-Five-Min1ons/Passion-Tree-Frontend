//รวมLearningPath (title, cover, instructor) กับ LearningPathProgress (progress %, status)ที่ต้องเอาไปใช้ในหน้าstatus

import 'learning_path.dart';
import 'learning_path_progress.dart';

class LearningPathWithProgress {
  final LearningPath path;
  final LearningPathProgress progress;

  const LearningPathWithProgress({required this.path, required this.progress});
}
