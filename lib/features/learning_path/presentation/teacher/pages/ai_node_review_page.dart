import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/teacher_nodes_overview.dart';

class AINodeReviewPage extends StatefulWidget {
  const AINodeReviewPage({super.key});

  @override
  State<AINodeReviewPage> createState() => _AINodeReviewPageState();
}

class _AINodeReviewPageState extends State<AINodeReviewPage> {
  final List<String> _nodes = [
    'ระบบนิเวศ',
    'ความสัมพันธ์ของสิ่งมีชีวิต',
    'สมดุลของป่า',
    'บทประยุกต์',
  ];

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
                  height: 420, // คุมความสูงกล่องตามดีไซน์
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
                          IconButton(
                            icon: const Icon(Icons.autorenew),
                            onPressed: _regenerateNodes,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ===== NODE LIST =====
                      Expanded(
                        child: ListView.builder(
                          itemCount: _nodes.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                  children: [
                                    TextSpan(
                                      text: 'Node${index + 1} : ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    TextSpan(text: _nodes[index]),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ===== BOTTOM ACTIONS =====
                Row(
                  children: [
                    const Spacer(), // ดันไปฝั่งขวา

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
                            builder: (_) => const TeacherNodesOverviewPage(
                              title: 'Nodes Overview',
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
    );
  }

  // ===== ACTIONS =====
  void _regenerateNodes() {
    setState(() {
      _nodes.shuffle(); // mock regenerate
    });
  }
}
