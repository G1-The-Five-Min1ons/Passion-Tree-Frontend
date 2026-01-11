import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

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

    return PixelBorderContainer(
      width: size ?? double.infinity,
      height: size,
      pixelSize: pixelSize,
      borderColor: primaryColor,
      fillColor: Colors.transparent,
      padding: EdgeInsets.all(pixelSize),
      child: ClipPath(
        clipper: _PixelCoverClipper(pixelSize),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Column(
            children: [
              // ส่วนรูปภาพ
              Expanded(
                flex: 68,
                child: imageUrl != null
                    ? Image.network(imageUrl!, fit: BoxFit.cover, width: double.infinity)
                    : Container(color: primaryColor.withOpacity(0.3)),
              ),
              // ส่วนแถบชื่อด้านล่าง
              Expanded(
                flex: 32,
                child: Container(
                  width: double.infinity,
                  color: primaryColor,
                  padding: EdgeInsets.all(pixelSize * 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: AppPixelTypography.smallTitle.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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