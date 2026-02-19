import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/delete_popup.dart';

class ActionPopUp extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ActionPopUp({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 240,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                context,
                label: 'Edit',
                color: Theme.of(context).colorScheme.onSurface,
                iconPath: 'assets/icons/Edit.png',
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              
              Center(
                child: SizedBox(
                  width: 230,
                  child: Divider(
                    height: 16,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              
              _buildActionButton(
                context,
                label: 'Delete',
                color: Theme.of(context).colorScheme.error,
                iconPath: 'assets/icons/Delete.png',
                onTap: () {
                  Navigator.pop(context);
                  
                  DeletePopUp.show(
                    context,
                    onDelete: () {
                      debugPrint('[ActionPopUp] Delete confirmed, executing onDelete callback');
                      onDelete();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required Color color,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Text(
              label,
              style: AppPixelTypography.smallTitle.copyWith(color: color),
            ),
            const Spacer(),
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
              filterQuality: FilterQuality.none,
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, {required VoidCallback onEdit, required VoidCallback onDelete}) {
    showDialog(
      context: context,
      builder: (context) => ActionPopUp(onEdit: onEdit, onDelete: onDelete),
    );
  }
}