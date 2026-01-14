import 'package:flutter/material.dart';

class MoreIcon extends StatelessWidget{
  final double dotSize;
  final double spacing;
  final Color? color;

  const MoreIcon({
    super.key,
    this.dotSize = 4,
    this.spacing = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context){
    final finalColor = color ?? Theme.of(context).colorScheme.onPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(finalColor),
        SizedBox(width: spacing),
        _buildDot(finalColor),
        SizedBox(width: spacing),
        _buildDot(finalColor),
      ],
    );
  }

  Widget _buildDot(Color color){
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}