import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

enum ArrowDirection { up, down, left, right }

class ArrowButton extends StatelessWidget {
  final ArrowDirection direction;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const ArrowButton({
    super.key,
    required this.direction,
    required this.onPressed,
    this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = direction == ArrowDirection.left
        ? Symbols.chevron_left_rounded
        : direction == ArrowDirection.right
        ? Symbols.chevron_right_rounded
        : direction == ArrowDirection.up
        ? Symbols.expand_less_rounded
        : Symbols.expand_more_rounded;

    final isHorizontal = direction == ArrowDirection.left ||
        direction == ArrowDirection.right;

    return IconButton(
      onPressed: onPressed,
      icon: Transform.scale(
        scaleX: isHorizontal ? 1.4 : 1.0,
        child: Icon(
          iconData,
          color: color ?? Theme.of(context).colorScheme.surface,
          size: size,
          weight: 500,
          grade: 200,
          opticalSize: 20,
        ),
      ),
    );
  }
}
