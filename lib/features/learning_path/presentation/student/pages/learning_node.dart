import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning_node/learning_node_content.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_quiz.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning_node/node_comments_section.dart';

class LearningNodePage extends StatelessWidget {
  const LearningNodePage({super.key});

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
                /// ===== NODE CONTENT =====
                LearningNodeContent(
                  title: 'Ecosystem',
                  description:
                      'หลักสูตรนี้มุ่งเน้นให้ผู้เรียนเข้าใจความสัมพันธ์ระหว่างสิ่งมีชีวิตกับสิ่งแวดล้อมในระบบนิเวศ เรียนรู้โครงสร้าง การทำงาน และความสมดุลของระบบนิเวศ รวมถึงผลกระทบจากกิจกรรมของมนุษย์และแนวทางการอนุรักษ์อย่างยั่งยืน',
                  materials: const ['Ecology.pdf', 'Ecosystem_summary.pdf'],

                  onTakeQuiz: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LearningPathQuizPage(),
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
