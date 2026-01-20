import 'package:flutter/material.dart';

class NodeItem extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;
  final double size;

  const NodeItem({
    super.key,
    required this.imagePath,
    this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}