import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/teacher_nodes_overview.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/generated_node.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

class AINodeReviewPage extends StatefulWidget {
  final String pathId;
  final String objective;

  const AINodeReviewPage({
    super.key,
    required this.pathId,
    required this.objective,
  });

  @override
  State<AINodeReviewPage> createState() => _AINodeReviewPageState();
}

class _AINodeReviewPageState extends State<AINodeReviewPage> {
  List<GeneratedNode> _nodes = [];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _generateNodes();
    }
  }

  void _generateNodes() {
    context.read<LearningPathBloc>().add(
      GenerateNodesWithAIEvent(
        topic: widget.objective,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<LearningPathBloc, LearningPathState>(
      listener: (context, state) {
        if (state is NodesGeneratedWithAI) {
          setState(() {
            _nodes = state.nodes;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Generated ${state.nodes.length} nodes')),
          );
        } else if (state is LearningPathError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
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
                        'Node review',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== PIXEL NODE CARD =====
                  PixelBorderContainer(
                    width: double.infinity,
                    height: 420,
                    padding: const EdgeInsets.all(16),
                    borderColor: colors.primary,
                    fillColor: colors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== CARD HEADER =====
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Nodes Contain in Path',
                                style: AppTypography.h3SemiBold.copyWith(
                                  color: colors.primary,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Refresh icon
                            BlocBuilder<LearningPathBloc, LearningPathState>(
                              builder: (context, state) {
                                final isLoading = state is LearningPathLoading;
                                return IconButton(
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.autorenew),
                                  onPressed: isLoading ? null : _generateNodes,
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ===== NODE LIST =====
                        BlocBuilder<LearningPathBloc, LearningPathState>(
                          builder: (context, state) {
                            if (state is LearningPathLoading) {
                              return const Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (_nodes.isEmpty) {
                              return Expanded(
                                child: Center(
                                  child: Text(
                                    'No nodes generated yet',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: colors.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Expanded(
                              child: ListView.builder(
                                itemCount: _nodes.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: RichText(
                                      text: TextSpan(
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Node${index + 1} : ',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(text: _nodes[index].title),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== BOTTOM ACTIONS =====
                  Row(
                    children: [
                      const Spacer(),

                      AppButton(
                        variant: AppButtonVariant.text,
                        text: 'Cancel',
                        backgroundColor: AppColors.scale,
                        textColor: AppColors.textPrimary,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      const SizedBox(width: 12),

                      AppButton(
                        variant: AppButtonVariant.text,
                        text: 'Save',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeacherNodesOverviewPage(
                                title: widget.objective,
                                aiNodes: _nodes,
                                pathId: widget.pathId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
