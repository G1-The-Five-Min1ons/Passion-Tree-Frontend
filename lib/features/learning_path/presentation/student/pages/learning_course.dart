
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/learning_course_content.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/student_nodes_overview.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/node_comments_section.dart';

class LearningCoursePage extends StatelessWidget {
  final LearningPath course;
  final EnrolledLearningPath? enrolledPath;

  const LearningCoursePage({
    super.key,
    required this.course,
    this.enrolledPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xmargin,
              right: AppSpacing.xmargin,
              top: AppSpacing.ymargin,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== COURSE CONTENT =====
                LearningCourseContent(
                  title: enrolledPath?.title ?? course.title,
                  description: enrolledPath?.description ?? course.description,
                  isEnrolled: enrolledPath != null,
                  onStartJourney: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentNodesOverviewPage(course: course),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                /// ===== COMMENTS =====
                const NodeCommentsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
