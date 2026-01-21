import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
class NodeInfoSection extends StatelessWidget {
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;

  const NodeInfoSection({
    super.key,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // ===== NODE TITLE =====
        PixelTextField(
          label: 'Node Title',
          hintText: 'Enter node title',
          height: 40,
          onChanged: onTitleChanged,
        ),

        const SizedBox(height: 12),

        // ===== NODE DESCRIPTION =====
        PixelTextField(
          label: 'Node Description',
          hintText: 'Enter node description',
          height: 40,
          onChanged: onDescriptionChanged,
        ),
      ],
    );
  }
}
