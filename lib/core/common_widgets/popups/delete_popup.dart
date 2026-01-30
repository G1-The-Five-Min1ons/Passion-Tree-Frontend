import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';

class DeletePopUp extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onDelete;

  const DeletePopUp({
    super.key,
    required this.title,
    required this.body,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 315,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppPixelTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            
              Text(
                body,
                style: AppTypography.subtitleRegular,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 26),

              SaveCancel(
                saveText: 'Delete',
                saveButtonColor: Theme.of(context).colorScheme.error,
                cancelText: 'Cancel',
                onCancel: () => Navigator.pop(context),
                onSave: () {
                  Navigator.pop(context);
                  onDelete(); 
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    String title = 'Delete?', 
    String body = 'Are you sure you want to delete?\nThis process cannot be undone.',
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      builder: (context) => DeletePopUp(
        title: title,
        body: body,
        onDelete: onDelete,
      ),
    );
  }
}