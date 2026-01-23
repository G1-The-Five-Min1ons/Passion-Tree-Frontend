import 'package:flutter/material.dart';

class CloseIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const CloseIcon({super.key, this.onPressed, this.color});
  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(Icons.close, color: iconColor),
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }
}

//---------------------- วิธีเรียกใช้ ----------------------//
/*
IconTheme(
                      data: const IconThemeData(size: 18),
                      child: CloseIcon(
                        color: colors.error,
                        onPressed: () => onRemoveFile(index),
                      ),
                    ),
*/