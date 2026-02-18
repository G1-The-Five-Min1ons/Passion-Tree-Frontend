import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/teacher_nodes_overview.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/ai_generate_model.dart';
import 'package:passion_tree_frontend/features/learning_path/data/services/learning_path_api_service.dart';

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
  bool _isLoading = true; // สถานะโหลด

  @override
  void initState() {
    super.initState();
    // เริ่มต้นมา ให้โหลดข้อมูลทันที
    _generateNodesFromAI();
  }

  // ฟังก์ชันแยกสำหรับเรียก AI (ใช้ซ้ำตอนกดปุ่ม Reload)
  Future<void> _generateNodesFromAI() async {
    if (widget.objective.isEmpty) {
        setState(() => _isLoading = false);
        return;
    }

    setState(() => _isLoading = true);

    try {
      final aiResponse = await generateNodeWithAI(widget.objective);
      
      setState(() {
        _nodes = aiResponse.nodes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('AI Error: $e');
      setState(() => _isLoading = false);
    }
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
                            onPressed: _isLoading ? null : _generateNodesFromAI,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ===== NODE LIST =====
                     Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              ) // หมุนๆ
                            : _nodes.isEmpty
                            ? const Center(child: Text("No nodes generated"))
                            : ListView.builder(
                                itemCount: _nodes.length,
                                itemBuilder: (context, index) {
                                  final node = _nodes[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: RichText(
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                        children: [
                                          TextSpan(
                                            text: 'Node${node.sequence} : ',
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
                                          TextSpan(text: node.title),
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
                      backgroundColor:
                          AppColors.scale,
                           textColor: AppColors.textPrimary,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),


                    const SizedBox(width: 12),

                    AppButton(
                      variant: AppButtonVariant.text,
                      text: 'Save',
                      onPressed: _isLoading 
                        ? () {} 
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TeacherNodesOverviewPage(
                                    title: 'Nodes Overview',
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
    );
  }
}
