import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
class NodeInfoSection extends StatelessWidget {

  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onLinkChanged;
  final VoidCallback onAddLink;
  final List<String> links;
  final String linkValue;
  final Function(int) onRemoveLink;

  const NodeInfoSection({
    super.key,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onLinkChanged,
    required this.onAddLink,
    required this.links,
    required this.linkValue,
    required this.onRemoveLink,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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

        const SizedBox(height: 12),

        // ===== MATERIALS =====
        Text(
          'Add Learning Materials',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        // ===== INPUT + ADD BUTTON =====
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: PixelTextField(
                label: 'Link (Optional)',
                hintText: 'e.g. Youtube link / Google Drive',
                height: 40,
                value: linkValue,
                onChanged: onLinkChanged,
              ),
            ),

            const SizedBox(width: 8),
            
            AppButton(
              variant: AppButtonVariant.text,
              text: 'Add',
              onPressed: onAddLink,
            ),
          ],
        ),

        const SizedBox(height: 10),
        // ===== LINK LIST =====
        ...List.generate(
          links.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    links[index],
                    style: AppTypography.subtitleSemiBold,
                       
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemoveLink(index),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
