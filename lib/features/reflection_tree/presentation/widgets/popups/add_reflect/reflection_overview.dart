import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class ReflectionOverview extends StatelessWidget {
  final String learn;
  final String feel;
  final int level;
  final int progress;
  final int challenge;

  final List<String> _levelImages = [
    'assets/images/emojis/level_1.png',
    'assets/images/emojis/level_2.png',
    'assets/images/emojis/level_3.png',
    'assets/images/emojis/level_4.png',
    'assets/images/emojis/level_5.png',
  ];

  ReflectionOverview({
    super.key,
    required this.learn,
    required this.feel,
    required this.level,
    required this.progress,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          if (level > 0)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Image.asset(_levelImages[level - 1], height: 120),
                ],
              ),
            ),
          
          const SizedBox(height: 20),
          
          Text("What you have learned :", style: AppTypography.titleSemiBold),
          const SizedBox(height: 8),
          Text(
            learn, 
            style: AppTypography.subtitleRegular,
          ),

          const SizedBox(height: 20),
          Text("How you feel about this :", style: AppTypography.titleSemiBold),
          const SizedBox(height: 8),
          Text(
            feel, 
            style: AppTypography.subtitleRegular,
          ),

          const SizedBox(height: 20),
          _buildScoreRow("Learning Progress", progress),
          const SizedBox(height: 12),
          _buildScoreRow("Challenging Level", challenge),

        ],
      )
    );
  }
  Widget _buildScoreRow(String title, int score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.titleSemiBold),
        Text(
          "$score/5", 
          style: AppTypography.titleSemiBold.copyWith(
            color: AppColors.primaryBrand,
          ),
        ),
      ],
    );
  }
}