import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/more_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/layout/fullscreen_image_viewer.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_course.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/action_popup.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';

class PixelCourseCard extends StatelessWidget {
  final LearningPath course;
  final bool showMoreIcon;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCardTap;

  const PixelCourseCard({
    super.key,
    required this.course,
    this.showMoreIcon = false,
    this.onEdit,
    this.onDelete,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final descriptionStyle = AppTypography.smallBodyMedium;
    final textScaler = MediaQuery.textScalerOf(context);

    // คำนวณความสูงของ Text ล่วงหน้า
    final descriptionHeightPainter = TextPainter(
      text: TextSpan(text: 'A\nA', style: descriptionStyle),
      maxLines: 2,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    final descriptionBlockHeight = descriptionHeightPainter.height + 2;

    return BaseCourseCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // คำนวณ Scale ตามความสูงของการ์ด
          final scale = (constraints.maxHeight / BaseCourseCard.defaultHeight)
              .clamp(0.6, 1.4);
          final imageHeight = (80 * scale).clamp(56.0, 160.0);

          return InkWell(
            // ย้าย InkWell มาไว้ข้างในเพื่อให้อยู่ภายใต้ constraints ที่ถูกต้อง
            borderRadius: BorderRadius.circular(8),
            onTap:
                onCardTap ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<LearningPathBloc>(),
                        child: LearningCoursePage(course: course),
                      ),
                    ),
                  );
                },
            child: Column(
              children: [
                // ================= IMAGE =================
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: course.coverImageUrl.isEmpty
                              ? null
                              : () => FullscreenImageViewer.show(
                                  context,
                                  imageUrl: course.coverImageUrl,
                                ),
                          child: Image.network(
                            course.coverImageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: colors.primary.withValues(alpha: 0.15),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40 * scale,
                                  color: colors.onPrimary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // ---------- STAR BADGE ----------
                      Positioned(
                        top: 3,
                        right: 3,
                        child: Container(
                          // ลบ SizedBox ที่ล็อกขนาดออกเพื่อให้ขยายตาม scale ได้
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          color: AppColors.cardBorder,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/Pixel_star.png',
                                width: 16 * scale,
                                height: 12 * scale,
                              ),
                              SizedBox(width: 4 * scale),
                              Text(
                                course.rating.toStringAsFixed(1),
                                style: AppTypography.bodySemiBold.copyWith(
                                  color: colors.secondary,
                                  fontSize:
                                      (AppTypography.bodySemiBold.fontSize ??
                                          14) *
                                      scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= INFO =================
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: colors.surface,
                    padding: EdgeInsets.all(AppSpacing.elementgap / 2 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                course.title,
                                style: AppTypography.subtitleSemiBold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (showMoreIcon)
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                splashRadius: 20 * scale,
                                icon: MoreIcon(color: colors.onSurface),
                                onPressed: () {
                                  ActionPopUp.show(
                                    context,
                                    onEdit: onEdit ?? () {},
                                    onDelete: onDelete ?? () {},
                                  );
                                },
                              ),
                          ],
                        ),
                        SizedBox(height: 5 * scale),
                        Text(
                          'สอนโดย ${course.instructor}',
                          style: AppTypography.smallBodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10 * scale),
                        SizedBox(
                          height:
                              descriptionBlockHeight *
                              scale, // เพิ่ม scale ให้ความสูง block
                          child: Text(
                            course.description,
                            style: descriptionStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(), // ใช้ Spacer เพื่อดันข้อมูลด้านล่างให้ติดขอบเสมอ
                        Text(
                          '${course.students} learners',
                          style: AppTypography.smallBodyMedium.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          '${course.modules} modules',
                          style: AppTypography.smallBodyMedium.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
