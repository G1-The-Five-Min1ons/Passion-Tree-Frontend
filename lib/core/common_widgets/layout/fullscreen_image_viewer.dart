import 'package:flutter/material.dart';

/// แสดงรูปภาพเต็มจอ พร้อม pinch-to-zoom และ tap เพื่อปิด
/// ใช้ทั้ง Learning Path cover และ Album cover ใน Reflect
class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? heroTag,
  }) {
    if (imageUrl.isEmpty) return Future<void>.value();
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) => FullscreenImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = InteractiveViewer(
      maxScale: 5,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.white, size: 64),
          );
        },
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: heroTag != null
                    ? Hero(tag: heroTag!, child: image)
                    : image,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
