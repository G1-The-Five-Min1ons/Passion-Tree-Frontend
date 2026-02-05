import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/student_quiz.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_quiz/quiz_question.dart'; 
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_quiz/quiz_result.dart'; 
import 'package:passion_tree_frontend/features/learning_path/data/mocks/student_quiz_mock.dart';

enum QuizViewState { answering, result }

class LearningPathQuizPage extends StatefulWidget {
  const LearningPathQuizPage({super.key});

  @override
  State<LearningPathQuizPage> createState() => _LearningPathQuizPageState();
}

class _LearningPathQuizPageState extends State<LearningPathQuizPage> {
  late List<QuizQuestionStudent> _questions;
  QuizViewState _viewState = QuizViewState.answering;

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

                      // ===== QUESTIONS / RESULT =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _buildQuizContent(),
                      ),

                      const SizedBox(height: 32),

                      // ===== ACTION BUTTON =====
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _viewState == QuizViewState.answering
                              ? AppButton(
                                  variant: AppButtonVariant.text,
                                  text: 'Submit',
                                  onPressed: _submitQuiz,
                                )
                              : AppButton(
                                  variant: AppButtonVariant.text,
                                  text: 'Finish',
                                  onPressed: _finishQuiz,
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

  // ===== BUILD CONTENT =====
  Widget _buildQuizContent() {
    if (_viewState == QuizViewState.answering) {
      return Column(
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
      );
    }

    // ===== RESULT VIEW =====
    return Column(
      children: List.generate(
        _questions.length,
        (index) => QuizResultQuestionWidget(question: _questions[index]),
      ),
    );
  }

  // ===== ACTIONS =====
  void _submitQuiz() {
    setState(() {
      _viewState = QuizViewState.result;
    });
  }

  void _finishQuiz() {
    Navigator.pop(context);
  }
}
