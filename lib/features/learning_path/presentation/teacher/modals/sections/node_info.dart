import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/uploaded_file.dart';
class NodeInfoSection extends StatelessWidget {

   final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;

  // Links
  final ValueChanged<String> onLinkChanged;
  final VoidCallback onAddLink;
  final List<String> links;
  final String linkValue;
  final Function(int) onRemoveLink;

  // Files
  final VoidCallback onUploadFile;
  final List<UploadedFileItem> files;
  final Function(int) onRemoveFile;

  const NodeInfoSection({
    super.key,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onLinkChanged,
    required this.onAddLink,
    required this.links,
    required this.linkValue,
    required this.onRemoveLink,
    required this.onUploadFile,
    required this.files,
    required this.onRemoveFile,
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
          height: 38,
          onChanged: onTitleChanged,
        ),

        const SizedBox(height: 12),

        // ===== NODE DESCRIPTION =====
        PixelTextField(
          label: 'Node Description',
          hintText: 'Enter node description',
          height: 38,
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
            padding: const EdgeInsets.only(bottom: 8, left: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    links[index],
                    style: AppTypography.subtitleSemiBold,
                       
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  onPressed: () => onRemoveLink(index),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ===== UPLOAD FILE =====
        Text('Upload File', style: AppTypography.titleSemiBold),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: onUploadFile,
          child: PixelBorderContainer(
            width: double.infinity,
            height: 150,
            padding: EdgeInsets.zero,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    'Click to upload or drag and drop file\nMax 200MB',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ===== FILE LIST =====
        Column(
          children: List.generate(files.length, (index) {
            final file = files[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 10),
              child: PixelBorderContainer(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        file.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subtitleSemiBold,
                      ),
                    ),
                    IconTheme(
                      data: const IconThemeData(size: 18),
                      child: CloseIcon(
                        color: colors.error,
                        onPressed: () => onRemoveFile(index),
                      ),
                    ),

                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
