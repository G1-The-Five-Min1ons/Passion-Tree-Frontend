import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/uploaded_file.dart';
import 'package:url_launcher/url_launcher.dart';

class NodeInfoSection extends StatelessWidget {
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final String? initialTitle;
  final String? initialDescription;
  final bool isTitleInvalid;
  final bool isDescriptionInvalid;
  final String? titleWarningText;
  final String? descriptionWarningText;

  // Video URL
  final String? videoUrlValue;
  final ValueChanged<String>? onVideoUrlChanged;
  final String? videoUrlWarningText;
  final bool isVideoUrlInvalid;

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
    this.isTitleInvalid = false,
    this.isDescriptionInvalid = false,
    this.titleWarningText,
    this.descriptionWarningText,
    this.videoUrlValue,
    this.onVideoUrlChanged,
    this.videoUrlWarningText,
    this.isVideoUrlInvalid = false,
    required this.onUploadFile,
    required this.files,
    required this.onRemoveFile,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Future<void> openRemoteFile(String? filePath) async {
      if (filePath == null || filePath.isEmpty) return;
      final uri = Uri.tryParse(filePath.trim());
      if (uri == null || !uri.hasScheme) return;
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== NODE TITLE =====
        PixelTextField(
          label: 'Node Title *',
          hintText: 'Enter node title',
          height: 35,
          value: initialTitle,
          fillColor: colors.surface,
          borderColor: isTitleInvalid ? AppColors.cancel : null,
          onChanged: isReadOnly ? null : onTitleChanged,
          readOnly: isReadOnly,
        ),

        if (titleWarningText != null && titleWarningText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 10),
            child: Text(
              titleWarningText!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.cancel),
            ),
          ),

        const SizedBox(height: 12),

        // ===== NODE DESCRIPTION =====
        PixelTextField(
          label: 'Node Description *',
          hintText: 'Enter node description',
          height: 35,
          value: initialDescription,
          fillColor: colors.surface,
          borderColor: isDescriptionInvalid ? AppColors.cancel : null,
          onChanged: isReadOnly ? null : onDescriptionChanged,
          readOnly: isReadOnly,
        ),

        if (descriptionWarningText != null &&
            descriptionWarningText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 10),
            child: Text(
              descriptionWarningText!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.cancel),
            ),
          ),

        const SizedBox(height: 12),

        // ===== VIDEO URL =====
        Stack(
          clipBehavior: Clip.none,
          children: [
            PixelTextField(
              label: 'Video URL',
              hintText: 'Enter YouTube video URL',
              height: 35,
              value: videoUrlValue,
              fillColor: colors.surface,
              borderColor: isVideoUrlInvalid ? AppColors.cancel : null,
              onChanged: isReadOnly ? null : (onVideoUrlChanged ?? (_) {}),
              readOnly: isReadOnly,
            ),

            if (videoUrlWarningText != null && videoUrlWarningText!.isNotEmpty)
              Positioned(
                right: 10,
                top: 31,
                child: Container(
                  color: colors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    videoUrlWarningText!,
                    style: AppTypography.smallBodyRegular.copyWith(
                      color: AppColors.cancel,
                    ),
                  ),
                ),
              ),
          ],
        ),
            

        const SizedBox(height: 12),

        // ===== MATERIALS =====
        if (!isReadOnly) ...
          [
            Text(
              'Upload Learning Materials',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            // ===== UPLOAD FILE =====
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
                      Icon(
                        Icons.upload,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click to upload or drag and drop file\nMax 200MB',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ]
        else if (files.isNotEmpty) ...
          [
            Text(
              'Learning Materials',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),
          ],
          

        // ===== FILE LIST =====
        Column(
          children: List.generate(files.length, (index) {
            final file = files[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PixelBorderContainer(
                width: double.infinity,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox.expand(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => openRemoteFile(file.path),
                          child: Text(
                            file.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.subtitleSemiBold.copyWith(
                              decoration:
                                  file.path != null &&
                                      Uri.tryParse(file.path!)?.hasScheme ==
                                          true
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      if (!isReadOnly)
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
              ),
            );
          }),
        ),
      ],
    );
  }
}
