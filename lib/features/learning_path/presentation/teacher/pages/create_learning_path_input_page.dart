import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_preview_card.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/ai_node_review_page.dart';

class CreateLearningPathInputPage extends StatefulWidget {
  const CreateLearningPathInputPage({super.key});

  @override
  State<CreateLearningPathInputPage> createState() =>
      _CreateLearningPathInputPageState();
}

class _CreateLearningPathInputPageState
    extends State<CreateLearningPathInputPage> {
  String _title = '';
  String _objectives = '';

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBarWidget(title: 'Learning Paths', showBackButton: true),
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
                  height: 120, // เพิ่มความสูงเพื่อรองรับ subtitle
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create a New \nLearning Path',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                

                      const SizedBox(height: 20), // ระยะห่างตามที่ต้องการ

                      Text(
                        'Fill in details to start a new path for your students',
                        style: AppTypography.subtitleSemiBold.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                
                // ===== PREVIEW CARD =====
                Center(
                  child: CoursePreviewCard(
                    title: _title,
                    instructor: 'อ.อะตอม', // ตอนนี้ยัง fix ได้
                    objectives: _objectives,
                    
                  ),
                ),


                const SizedBox(height: 20),

                // ===== PATH TITLE =====
              
                PixelTextField(
                  label: 'Path Title',
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  hintText: 'Enter learning path title',
                  height: 38,
                  onChanged: (value) {
                    setState(() {
                      _title = value;
                    });
                  },
                ),


                const SizedBox(height: 20),

                // ===== UPLOAD COVER : TITLE =====
               
                Text(
                  'Upload Cover Image',
                  style: AppTypography.titleSemiBold.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),


                const SizedBox(height: 10),

                PixelBorderContainer(
                  width: double.infinity,
                  height: 150,
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload Cover Image',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 20),
                // ===== OBJECTIVES : TITLE =====

                PixelTextField(
                  label: 'Path Objectives',
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  hintText: 'Enter learning path objectives',
                  height: 38,
                  onChanged: (value) {
                    setState(() {
                      _objectives = value;
                    });
                  },
                ),



                const SizedBox(height: 20),

                // ===== DESCRIPTION : CONTENT =====
                PixelTextField(
                  label: 'Path Description',
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  hintText: 'Describe this learning path in detail',
                  height: 150,
                  onChanged: (value) {},
                ),

                const SizedBox(height: 30),

              // ===== Buttons =====
              //AI CREATE NODE
                Center(
                  child: Column(
                    children: [
                      AppButton(
                        variant: AppButtonVariant.text,
                        text: 'AI Create Node',
                        subText:
                            'Use AI powered to auto generate nodes for you',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AINodeReviewPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      //or
                      Text('or', style: AppPixelTypography.smallTitle.copyWith(color: Theme.of(context).colorScheme.onPrimary),),

                      // Plain Path
                      const SizedBox(height: 10),
                      AppButton(
                        variant: AppButtonVariant.text,
                        text: 'Create Plain Path',
                        subText: 'Create nodes by yourself',
                        onPressed: () {},
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
}
