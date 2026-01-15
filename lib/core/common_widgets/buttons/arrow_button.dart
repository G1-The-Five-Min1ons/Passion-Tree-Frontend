import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

enum ArrowDirection { up, down, left, right}

class ArrowButton extends StatelessWidget{
  final ArrowDirection direction;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const ArrowButton({
    super.key,
    required this.direction,
    required this.onPressed,
    this.color,
    this.size = 35,
  });

  @override 
  Widget build(BuildContext context){
    IconData getIcon(){
      switch (direction){
        case ArrowDirection.up: return Symbols.chevron_left_rounded;
        case ArrowDirection.down: return Symbols.keyboard_arrow_down_rounded;
        case ArrowDirection.left: return Symbols.chevron_left_rounded;
        case ArrowDirection.right: return Symbols.chevron_left_rounded;
      }
    }
    
    final iconData = direction == ArrowDirection.left ? Symbols.chevron_left_rounded :
                   direction == ArrowDirection.right ? Symbols.chevron_right_rounded :
                   direction == ArrowDirection.up ? Symbols.expand_less_rounded :
                   Symbols.expand_more_rounded;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        iconData,
        color: color ?? Theme.of(context).colorScheme.surface,
        size: size,
        weight: 400,
      ),
    );
  }
}