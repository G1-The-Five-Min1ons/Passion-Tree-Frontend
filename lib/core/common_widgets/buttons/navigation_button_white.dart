import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';

class NavigationButtonWhite extends StatelessWidget {
  final NavigationDirection direction;
  final VoidCallback onPressed;

  const NavigationButtonWhite({
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

  /// ขนาดปุ่ม 
  double _size() => 20;

  /// path ของ white navigation button (ซ้าย / ขวา เท่านั้น)
  String _assetPath() {
    switch (direction) {
      case NavigationDirection.left:
        return 'assets/buttons/navigation/white/left_white.png';
      case NavigationDirection.right:
        return 'assets/buttons/navigation/white/right_white.png';
      default:
        throw UnsupportedError(
          'NavigationButtonWhite supports only left & right directions',
        );
    }
  }
}


//---------------------- วิธีเรียกใช้ ----------------------//
/*เลือกทิศทางที่ต้องการใช้
 NavigationButtonWhite(
                  direction: NavigationDirection.left,
                  onPressed: () {
                    debugPrint('Left pressed');
                  },
                ),
*/