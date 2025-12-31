// ทำให้ reuse icon pixel ได้ง่ายขึ้น
import 'package:flutter/material.dart';

class PixelIcon extends StatelessWidget {
  final String asset;
  final double size;

  const PixelIcon(
    this.asset, {
    super.key,
    this.size = 16, // ค่า default ตาม Figma
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      filterQuality: FilterQuality.none, //สำคัญไม่งั้นพิกเซลจะถูกเบลอ
    );
  }
}
