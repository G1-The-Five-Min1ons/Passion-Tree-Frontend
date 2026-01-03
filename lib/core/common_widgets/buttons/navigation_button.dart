import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';

class NavigationButton extends StatelessWidget {
  final NavigationDirection direction;
  final VoidCallback onPressed;

  const NavigationButton({
    super.key,
    required this.direction,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        _assetPath(),
        width: _size(),
        height: _size(),
        fit: BoxFit.contain,
      ),
    );
  }

  /// ขนาดปุ่ม (อิงจาก Figma)
  double _size() => 30;

  /// path ของ pixel navigation button
  String _assetPath() {
    switch (direction) {
      case NavigationDirection.left:
        return 'assets/buttons/navigation/pixel/left_small_light.png';
      case NavigationDirection.right:
        return 'assets/buttons/navigation/pixel/right_small_light.png';
      case NavigationDirection.up:
        return 'assets/buttons/navigation/pixel/up_small_light.png';
      case NavigationDirection.down:
        return 'assets/buttons/navigation/pixel/down_small_light.png';
    }
  }
}
