import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/student_quiz.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_quiz/quiz_question.dart'; 
import 'package:passion_tree_frontend/features/learning_path/data/mocks/student_quiz_mock.dart ';

class LearningPathQuizPage extends StatefulWidget {
  const LearningPathQuizPage({super.key});

  @override
  State<LearningPathQuizPage> createState() => _LearningPathQuizPageState();
}

class _LearningPathQuizPageState extends State<LearningPathQuizPage> {
  late List<QuizQuestionStudent> _questions;

  @override
  void initState() {
    super.initState();
    // clone เพื่อไม่แก้ reference ของ mock
    _questions = List.from(mockStudentQuiz.questions);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
                // ===== HEADER =====
                SizedBox(
                  height: 72,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      mockStudentQuiz.title,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ===== QUIZ CARD =====
                PixelBorderContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  borderColor: colors.primary,
                  fillColor: colors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== QUIZ TITLE =====
                      Text(
                        'Quiz',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(color: colors.primary),
                      ),

                      const SizedBox(height: 24),

                      // ===== QUESTIONS =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: List.generate(
                            _questions.length,
                            (index) => QuizQuestionWidget(
                              question: _questions[index],
                              onSelect: (choiceIndex) {
                                setState(() {
                                  _questions[index].selectedIndex = choiceIndex;
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ===== SUBMIT BUTTON (ขยับเข้ามา) =====
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: AppButton(
                            variant: AppButtonVariant.text,
                            text: 'Submit',
                            onPressed: _submitQuiz,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitQuiz() {
    debugPrint('Submit quiz');
    // step ถัดไป: เปลี่ยนเป็น result view
  }
}
