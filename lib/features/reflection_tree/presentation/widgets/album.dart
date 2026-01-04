import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class _PixelAlbumPainter extends CustomPainter {
  final Color color;
  final double pixelSize;
  final Color fillColor;

  _PixelAlbumPainter({
    required this.color,
    required this.pixelSize,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    double p = pixelSize;
    double s = p * 0.5;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(p * 2, p * 2, w - (p * 4), h - (p * 4)), fillPaint);
    canvas.drawRect(Rect.fromLTWH(p * 3, 0, w - (p * 6), h), fillPaint);
    canvas.drawRect(Rect.fromLTWH(0, p * 3, w, h - (p * 6)), fillPaint);

    // --- 1. เส้นขอบตรงหลัก ---
    canvas.drawRect(Rect.fromLTWH(p * 2, 0, w - (p * 4), p), borderPaint); // บน
    canvas.drawRect(Rect.fromLTWH(0, p * 2, p, h - (p * 4)), borderPaint); // ซ้าย
    canvas.drawRect(Rect.fromLTWH(w - p - s, p * 2, p + s, h - (p * 4)), borderPaint); // ขวา
    canvas.drawRect(Rect.fromLTWH(p * 2, h - p - s, w - (p * 4), p + s), borderPaint); // ล่าง

    // --- 2. รอยหยักมุม ---
    // มุมบนซ้าย
    canvas.drawRect(Rect.fromLTWH(p * 2, p, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, p, p, p * 2), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, p * 2, p, p), borderPaint);

    // มุมบนขวา
    canvas.drawRect(Rect.fromLTWH(w - (p * 3) - s, p, p, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, p, p + s, p), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, p * 2, p + s, p), borderPaint);

    // มุมล่างซ้าย
    canvas.drawRect(Rect.fromLTWH(p * 2, h - (p * 2) - s, p, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, h - (p * 2) - s, p, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(p, h - (p * 3) - s, p, p), borderPaint);

    // มุมล่างขวา
    canvas.drawRect(Rect.fromLTWH(w - (p * 3) - s, h - (p * 2) - s, p, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, h - (p * 2) - s, p + s, p + s), borderPaint);
    canvas.drawRect(Rect.fromLTWH(w - (p * 2) - s, h - (p * 3) - s, p + s, p), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PixelAlbumCover extends StatelessWidget {
  final double? size;
  final double pixelSize;
  final Color? color;
  final String? imageUrl;
  final String? title;
  final String? subtitle;

  const PixelAlbumCover({
    super.key,
    this.size,
    this.pixelSize = 3.0,
    this.color,
    this.imageUrl,
    this.title,
    this.subtitle
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size ?? double.infinity,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: Stack(
          children: [
            // ชั้นที่ 1: รูปภาพพื้นหลัง
              Positioned.fill(
                child: ClipPath(
                  clipper: _PixelCoverClipper(pixelSize),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 68,
                        child: imageUrl != null
                            ? Image.network(imageUrl!, fit: BoxFit.cover,width: double.infinity,)
                            : Container(color: primaryColor,),
                      ),
                      Expanded(
                        flex: 32, 
                        child: Container(
                          width: double.infinity,
                          color: primaryColor,
                          padding: EdgeInsets.only(
                            left: pixelSize * 2,
                            right: pixelSize * 2,
                            top: pixelSize * 2,
                          ),
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (title != null)
                              Text(
                                  title!,
                                  style: AppPixelTypography.smallTitle.copyWith(
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 2),
                              if (subtitle != null)
                              Text(
                                subtitle!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ชั้นที่ 2: ขอบพิกเซล 
          Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _PixelAlbumPainter(
                    color: primaryColor,
                    pixelSize: pixelSize,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelCoverClipper extends CustomClipper<Path> {
  final double p; 

  _PixelCoverClipper(this.p);

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path path = Path();

    // วาด Path ให้เว้าตามรอยหยักพิกเซล 
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