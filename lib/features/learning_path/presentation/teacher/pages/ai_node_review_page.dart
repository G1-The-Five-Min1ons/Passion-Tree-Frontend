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
  // [แก้ไข] รับแค่ pathId ก็พอ
  final String pathId;

  const AINodeReviewPage({
    super.key,
    required this.pathId,
  });

  @override
  State<AINodeReviewPage> createState() => _AINodeReviewPageState();
}

class _AINodeReviewPageState extends State<AINodeReviewPage> {
  List<GeneratedNode> _nodes = [];
  bool _isLoading = true; // สถานะโหลด
  String _objective = ''; // เก็บ objective ไว้ใช้ตอน regenerate

  @override
  void initState() {
    super.initState();
    // เริ่มต้นมา ให้โหลดข้อมูลทันที
    _fetchAndGenerate();
  }

  // ฟังก์ชันหลัก: ดึงข้อมูล -> สร้าง AI
  Future<void> _fetchAndGenerate() async {
    try {
      // 1. ดึงข้อมูล Path เพื่อเอา Objective
      // final pathData = await getLearningPathById(widget.pathId);
      final objectiveFromApi = pathData['objective'] ?? ''; // ดึง field objective
      
      setState(() {
        _objective = objectiveFromApi;
      });

      // 2. เรียก AI Generate โดยใช้ objective ที่ได้มา
      await _generateNodesFromAI();

    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // ฟังก์ชันแยกสำหรับเรียก AI (ใช้ซ้ำตอนกดปุ่ม Reload)
  Future<void> _generateNodesFromAI() async {
    if (_objective.isEmpty) return;

    setState(() => _isLoading = true); // หมุนติ้วๆ

    try {
      // เรียก service generatePathWithAI (อันเดิมที่มีอยู่แล้ว)
      final aiResponse = await generatePathWithAI(_objective);
      
      setState(() {
        _nodes = aiResponse.nodes;
        _isLoading = false; // หยุดหมุน
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
                      // ปิดปุ่ม Save ถ้ากำลังโหลดอยู่
                      onPressed: _isLoading 
                        ? () {} 
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TeacherNodesOverviewPage(
                                    title: 'Nodes Overview'),
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
  // void _regenerateNodes() {
  //   setState(() {
  //     _nodes.shuffle(); // mock regenerate
  //   });
  // }

  // void _saveNodes() {
  //   debugPrint('Saved nodes: $_nodes');
  //   // TODO: ไป step ถัดไป
  // }
}
