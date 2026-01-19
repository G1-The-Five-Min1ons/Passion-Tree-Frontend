

import 'package:flutter/material.dart';

class NodeCanvas extends StatelessWidget {
  final double height;
  final EdgeInsets padding;
  final List<Widget> children;

  const NodeCanvas({
    super.key,
    required this.height,
    required this.children,
    this.padding = const EdgeInsets.only(top: 100, bottom: 100),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: SizedBox(
          height: height,
          child: Stack(clipBehavior: Clip.none, children: children),
        ),
      ),
    );
  }
}
