import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/learning_course_content.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_node.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/node_comments_section.dart';

class LearningCoursePage extends StatelessWidget {
  const LearningCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: false),
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
                  title: 'Biology101',
                  description:
                      'หลักสูตรนี้มุ่งเน้นให้ผู้เรียนเข้าใจความสัมพันธ์ระหว่างสิ่งมีชีวิตกับสิ่งแวดล้อมในระบบนิเวศ เรียนรู้โครงสร้าง การทำงาน และความสมดุลของระบบนิเวศ รวมถึงผลกระทบจากกิจกรรมของมนุษย์และแนวทางการอนุรักษ์อย่างยั่งยืน',
                  onStartJourney: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LearningNodePage(),
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
