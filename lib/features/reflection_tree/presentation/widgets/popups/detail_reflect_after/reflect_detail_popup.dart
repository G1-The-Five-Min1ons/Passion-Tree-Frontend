import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/detail_reflect_after/ai_analysis_content.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/detail_reflect_after/detail_reflect_content.dart';

class ReflectDetailPopup extends StatefulWidget {
  final String nodeName;
  final int level;
  final String learn;
  final String feel;
  final int progress;
  final int challenge;
  final String sentiment;
  final double reflectionScore;
  final String summary;
  final String strugglePoint;


  const ReflectDetailPopup({
    super.key,
    this.nodeName = '',
    this.level = 0,
    this.learn = '',
    this.feel = '',
    this.progress = 0,
    this.challenge = 0,
    this.sentiment = '',
    this.reflectionScore = 0,
    this.summary = '',
    this.strugglePoint = '',
  });

  static void show(
    BuildContext context, {
    String nodeName = '',
    int level = 0,
    String learn = '',
    String feel = '',
    int progress = 0,
    int challenge = 0,
    String sentiment = '',
    double reflectionScore = 0,
    String summary = '',
    String strugglePoint = '',
  }) {
    showDialog(
      context: context,
      builder: (context) => ReflectDetailPopup(
        nodeName: nodeName,
        level: level,
        learn: learn,
        feel: feel,
        progress: progress,
        challenge: challenge,
        sentiment: sentiment,
        reflectionScore: reflectionScore,
        summary: summary,
        strugglePoint: strugglePoint,
      ),
    );
  }

  @override
  State<ReflectDetailPopup> createState() => _ReflectDetailPopupState();
}

class _ReflectDetailPopupState extends State<ReflectDetailPopup> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 380,
            height: 680,
            child: PixelBorderContainer(
              pixelSize: 4,
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              style: AppTypography.h3SemiBold.copyWith(color: AppColors.textPrimary),
                              children: [
                                const TextSpan(text: "Node : "),
                                TextSpan(
                                  text: widget.nodeName,
                                  style: AppTypography.h3SemiBold.copyWith(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: Image.asset(
                              'assets/images/emojis/level_${widget.level}.png',
                              height: 160,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTabItem(title: "Reflection", index: 0),
                          const SizedBox(width: 16),
                          _buildTabItem(title: "AI Analysis", index: 1),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 350,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrand,
                        ),
                        child: SingleChildScrollView(
                          child: _selectedTab == 0 
                            ? DetailReflectContent(
                              learn: widget.learn,
                              feel: widget.feel,
                              progress: widget.progress,
                              challenge: widget.challenge,
                              ) 
                            : AIAnalysisContent(
                              sentiment: widget.sentiment,
                              reflectScore: widget.reflectionScore,
                              summary: widget.summary,
                              strugglePoint: widget.strugglePoint,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 8,
            top: 8,
            child: CloseIcon(
              color: AppColors.textSecondary,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    bool isSelected = _selectedTab == index;

    final Color activeColor = AppColors.primaryBrand;
    final Color inactiveColor = AppColors.textSecondary;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        child: Text(
          title,
          style: isSelected 
          ? AppTypography.subtitleMedium.copyWith(color: AppColors.surface)
          : AppTypography.subtitleRegular.copyWith(color: AppColors.surface),
        ),
      ),
    );
  }
}