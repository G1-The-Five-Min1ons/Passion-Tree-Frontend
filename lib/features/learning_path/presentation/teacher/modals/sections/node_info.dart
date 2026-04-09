import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/uploaded_file.dart';

class NodeInfoSection extends StatelessWidget {
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final String? initialTitle;
  final String? initialDescription;

  // Video URL
  final String? videoUrlValue;
  final ValueChanged<String>? onVideoUrlChanged;
  final String? videoUrlWarningText;

  // Files
  final VoidCallback onUploadFile;
  final List<UploadedFileItem> files;
  final Function(int) onRemoveFile;
  final bool isReadOnly;

  const NodeInfoSection({
    super.key,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    this.initialTitle,
    this.initialDescription,
    this.videoUrlValue,
    this.onVideoUrlChanged,
    this.videoUrlWarningText,
    required this.onUploadFile,
    required this.files,
    required this.onRemoveFile,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== NODE TITLE =====
        PixelTextField(
          label: 'Node Title *',
          hintText: 'Enter node title',
          height: 35,
          value: initialTitle,
          onChanged: isReadOnly ? null : onTitleChanged,
          readOnly: isReadOnly,
        ),

        const SizedBox(height: 12),

        // ===== NODE DESCRIPTION =====
        PixelTextField(
          label: 'Node Description *',
          hintText: 'Enter node description',
          height: 35,
          value: initialDescription,
          onChanged: isReadOnly ? null : onDescriptionChanged,
          readOnly: isReadOnly,
        ),

        const SizedBox(height: 12),

        // ===== VIDEO URL =====
        PixelTextField(
          label: 'Video URL *',
          hintText: 'Enter YouTube video URL',
          height: 35,
          value: videoUrlValue,
          onChanged: isReadOnly ? null : (onVideoUrlChanged ?? (_) {}),
          readOnly: isReadOnly,
        ),

        if (videoUrlWarningText != null && videoUrlWarningText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 10),
            child: Text(
              videoUrlWarningText!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.cancel,
              ),
            ),
          ),

        const SizedBox(height: 12),

        // ===== MATERIALS =====
        Text(
          'Upload Learning Materials',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        // ===== UPLOAD FILE =====
        GestureDetector(
          onTap: isReadOnly ? null : onUploadFile,
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
                      child: isReadOnly
                          ? const SizedBox.shrink()
                          : CloseIcon(
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
