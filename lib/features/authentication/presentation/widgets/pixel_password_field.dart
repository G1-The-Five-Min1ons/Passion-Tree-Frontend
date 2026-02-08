import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class PixelPasswordField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final double height;
  final double? width;
  final ValueChanged<String>? onChanged;

  const PixelPasswordField({
    super.key,
    required this.label,
    this.hintText = '',
    this.controller,
    this.obscureText = true,
    this.height = 46.0,
    this.width,
    this.onChanged,
  });
  @override
  State<PixelPasswordField> createState() => _PixelPasswordFieldState();
}

class _PixelPasswordFieldState extends State<PixelPasswordField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PixelTextField(
          label: widget.label,
          hintText: widget.hintText,
          controller: widget.controller,
          isPassword: false,
          obscureText: _isObscure, 
          height: widget.height,
          width: widget.width,
          maxLines: 1,
          onChanged: widget.onChanged,
        ),
        Positioned(
          right: 12,
          bottom: 11, 
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
            child: Icon(
              _isObscure ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}