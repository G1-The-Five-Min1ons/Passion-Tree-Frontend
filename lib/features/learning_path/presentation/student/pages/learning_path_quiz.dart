import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/quiz_question.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_quiz/quiz_question.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_quiz/quiz_result.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/popups/student/congrats_popups.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/popups/student/rating_popup.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/learning_path/data/datasources/learning_path_data_source.dart';
import 'package:passion_tree_frontend/features/learning_path/data/repositories/learning_path_repositories.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/node_questions_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_status_page.dart';

enum QuizViewState { loading, answering, result, error }

class LearningPathQuizPage extends StatefulWidget {
  final String nodeId;
  final String? title;
  final String? pathName;
  final int? totalNodes;
  final int? currentNodeSequence;
  final String userId;

  const LearningPathQuizPage({
    super.key,
    required this.nodeId,
    this.title,
    this.pathName,
    this.totalNodes,
    this.currentNodeSequence,
    required this.userId,
  });

  @override
  State<LearningPathQuizPage> createState() => _LearningPathQuizPageState();
}

class _LearningPathQuizPageState extends State<LearningPathQuizPage> {
  List<QuizQuestion> _questions = [];
  QuizViewState _viewState = QuizViewState.loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _viewState = QuizViewState.loading;
      _errorMessage = null;
    });

    try {
      final dataSource = LearningPathDataSource();
      final repository = LearningPathRepositoryImpl(dataSource);
      final getNodeQuestions = GetNodeQuestions(repository);

      final questions = await getNodeQuestions(widget.nodeId);

      setState(() {
        _questions = questions;
        _viewState = QuizViewState.answering;
      });
    } catch (e) {
      setState(() {
        _viewState = QuizViewState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: true),
      body: SafeArea(child: _buildBody(colors)),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_viewState == QuizViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewState == QuizViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading quiz',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              variant: AppButtonVariant.text,
              text: 'Retry',
              onPressed: _loadQuestions,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
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
                  widget.title ?? 'Quiz',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(color: colors.onPrimary),
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
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: colors.primary),
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
              LogHandler.info(
                'Action: User answered question index $index, selected choice $choiceIndex in node ${widget.nodeId}',
              );
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
    // ตรวจสอบว่าเลือกคำตอบครบทุกข้อหรือยัง
    final unansweredQuestions = <int>[];
    for (int i = 0; i < _questions.length; i++) {
      if (_questions[i].selectedIndex == null) {
        unansweredQuestions.add(i + 1);
      }
    }

    // ถ้ายังไม่ได้เลือกครบ แสดง SnackBar เตือน
    if (unansweredQuestions.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unansweredQuestions.length == 1
                ? 'Please answer question'
                : 'Please answer all questions',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // ถ้าเลือกครบแล้ว เปลี่ยนเป็น result view
    setState(() {
      _viewState = QuizViewState.result;
    });
  }

  void _finishQuiz() {
    final userId = widget.userId;

    // Check if this is the last node (sequence starts from 1)

    final isLastNode =
        widget.totalNodes != null &&
        widget.currentNodeSequence != null &&
        widget.currentNodeSequence == widget.totalNodes;

    // Only show popups if this is the last node
    if (isLastNode && widget.pathName != null) {
      // Store references to avoid context issues
      final scaffoldContext = context;
      final bloc = context.read<LearningPathBloc>();

      // Show congratulation popup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (congratsDialogContext) => CompletionPopup(
          onYes: () {
            // Note: CompletionPopup already handles Navigator.pop internally

            // Show rating popup
            showDialog(
              context: scaffoldContext,
              barrierDismissible: false,
              builder: (ratingDialogContext) => RatingPopup(
                pathName: widget.pathName!,
                onSubmit: () async {
                  Navigator.of(
                    ratingDialogContext,
                  ).pop(); // Close rating popup first

                  LogHandler.info(
                    'Action: User completed and tracked progress for node ${widget.nodeId}',
                  );
                  // Mark node as completed
                  bloc.add(
                    CompleteNodeEvent(nodeId: widget.nodeId, userId: userId),
                  );

                  // Wait for backend to process completion (1 second)
                  await Future.delayed(const Duration(milliseconds: 1000));

                  // Navigate to status page after completion
                  Navigator.of(scaffoldContext).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: const LearningPathStatusPage(),
                      ),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
            );
          },
          onNo: () async {
            // Note: CompletionPopup already handles Navigator.pop internally

            LogHandler.info(
              'Action: User completed and tracked progress for node ${widget.nodeId}',
            );
            // Mark node as completed
            bloc.add(CompleteNodeEvent(nodeId: widget.nodeId, userId: userId));

            // Wait for backend to process completion (1 second)
            await Future.delayed(const Duration(milliseconds: 1000));

            // Navigate to status page after completion
            Navigator.of(scaffoldContext).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: bloc,
                  child: const LearningPathStatusPage(),
                ),
              ),
              (route) => route.isFirst,
            );
          },
        ),
      );
    } else {
      // Not the last node - complete node first, then go back

      LogHandler.info(
        'Action: User completed and tracked progress for node ${widget.nodeId}',
      );
      // Mark node as completed
      context.read<LearningPathBloc>().add(
        CompleteNodeEvent(nodeId: widget.nodeId, userId: userId),
      );

      Navigator.pop(context); // Pop quiz page
      Navigator.pop(
        context,
      ); // Pop learning node page -> back to nodes overview
    }
  }
}
