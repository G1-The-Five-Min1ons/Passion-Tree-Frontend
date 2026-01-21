import 'package:flutter/material.dart';

class PositionedNode extends StatelessWidget {
  final Offset position;
  final Widget child;
  final bool draggable;
  final VoidCallback? onTap;

  const PositionedNode({
    super.key,
    required this.position,
    required this.child,
    this.draggable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget node = GestureDetector(onTap: onTap, child: child);

    if (draggable) {
      node = Draggable(
        feedback: Material(color: Colors.transparent, child: child),
        childWhenDragging: Opacity(opacity: 0.4, child: child),
        child: node,
      );
    }

    return Positioned(top: position.dy, left: position.dx, child: node);
  }
}
