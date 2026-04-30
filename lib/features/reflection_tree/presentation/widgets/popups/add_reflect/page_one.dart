import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class PageOneView extends StatelessWidget {
  final Function(String) onLearnChanged;
  final String initialValue;
  final String nodeName;

  const PageOneView({
    super.key,
    required this.onLearnChanged,
    required this.initialValue,
    required this.nodeName,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Node: $nodeName', style: AppTypography.h3SemiBold),
                  const SizedBox(height: 12),
                  Text(
                    "What have you learned",
                    style: AppTypography.h3Regular,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 12),
                  PixelTextField(
                    pixelSize: 3,
                    hintText: 'Type what you have learned (Require)',
                    height: 320,
                    value: initialValue,
                    onChanged: onLearnChanged,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
