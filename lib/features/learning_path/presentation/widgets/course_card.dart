import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';

/// =======================================================
/// Pixel Painter (private)
/// =======================================================
class _PixelCoursePainter extends CustomPainter {
  final Color color;
  final double pixelSize;
  final Color fillColor;

  _PixelCoursePainter({
    required this.color,
    required this.pixelSize,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = pixelSize;
    final s = p * 0.5;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // fill
    canvas.drawRect(
      Rect.fromLTWH(p * 2, p * 2, w - (p * 4), h - (p * 4)),
      fillPaint,
    );
    canvas.drawRect(Rect.fromLTWH(p * 3, 0, w - (p * 6), h), fillPaint);
    canvas.drawRect(Rect.fromLTWH(0, p * 3, w, h - (p * 6)), fillPaint);

    // borders
    canvas.drawRect(Rect.fromLTWH(p * 2, 0, w - (p * 4), p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(0, p * 2, p, h - (p * 4)), borderPaint);
    canvas.drawRect(
      Rect.fromLTWH(w - p - s, p * 2, p + s, h - (p * 4)),
      borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(p * 2, h - p - s, w - (p * 4), p + s),
      borderPaint,
    );

    // corners
    canvas.drawRect(Rect.fromLTWH(p * 2, p, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, p, p, p * 2), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, p * 2, p, p), borderPaint);

    canvas.drawRect(Rect.fromLTWH(w - (p * 3) - s, p, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, p, p + s, p), borderPaint);
    canvas.drawRect(
      Rect.fromLTWH(w - (p * 2) - s, p * 2, p + s, p),
      borderPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(p * 2, h - (p * 2) - s, p, p + s),
      borderPaint,
    );
    canvas.drawRect(Rect.fromLTWH(p, h - (p * 2) - s, p, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, h - (p * 3) - s, p, p), borderPaint);

    canvas.drawRect(
      Rect.fromLTWH(w - (p * 3) - s, h - (p * 2) - s, p, p + s),
      borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w - (p * 2) - s, h - (p * 2) - s, p + s, p + s),
      borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w - (p * 2) - s, h - (p * 3) - s, p + s, p),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// =======================================================
/// Clipper (private)
/// =======================================================
class _PixelCourseClipper extends CustomClipper<Path> {
  final double p;
  _PixelCourseClipper(this.p);

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    path.moveTo(p * 2, 0);
    path.lineTo(w - p * 2, 0);
    path.lineTo(w - p * 2, p);
    path.lineTo(w - p, p);
    path.lineTo(w - p, p * 2);
    path.lineTo(w, p * 2);
    path.lineTo(w, h - p * 2);
    path.lineTo(w - p, h - p * 2);
    path.lineTo(w - p, h - p);
    path.lineTo(w - p * 2, h - p);
    path.lineTo(w - p * 2, h);
    path.lineTo(p * 2, h);
    path.lineTo(p * 2, h - p);
    path.lineTo(p, h - p);
    path.lineTo(p, h - p * 2);
    path.lineTo(0, h - p * 2);
    path.lineTo(0, p * 2);
    path.lineTo(p, p * 2);
    path.lineTo(p, p);
    path.lineTo(p * 2, p);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PixelCourseCard extends StatelessWidget {
  static const double cardWidth = 180;
  static const double cardHeight = 245;

  final Course course;
  final double pixelSize;
  final Color? color;

  const PixelCourseCard({
    super.key,
    required this.course,
    this.pixelSize = 3,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: _PixelCourseClipper(pixelSize),
              child: Column(
                children: [
                  // Image (mock)
                  SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: Container(
                      color: colors.primary.withValues(alpha: 0.15),
                      alignment: Alignment.center,
                      child: Text(
                        'IMAGE',
                        style: AppPixelTypography.smallTitle,
                      ),
                    ),
                  ),

                  // Info
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: colors.surface,
                      padding: EdgeInsets.all(AppSpacing.elementgap / 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------- Title + menu ----------
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
                              Icon(
                                Icons.more_horiz,
                                size: 16,
                                color: colors.onSurface,
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          // ---------- Instructor ----------
                          Text(
                            'สอนโดย อ.อะตอม',
                            style: AppTypography.smallBodyMedium,
                          ),

                          const SizedBox(height: 10),

                          // ---------- Description ----------
                          Text(
                            course.description,
                            style: AppTypography.smallBodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 10),

                          // ---------- Bottom info ----------
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${course.students} learners',
                                style: AppTypography.smallBodyMedium,
                              ),
                              Text(
                                '${course.modules} modules',
                                style: AppTypography.smallBodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PixelCoursePainter(
                  color: color ?? colors.primary,
                  pixelSize: pixelSize,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
