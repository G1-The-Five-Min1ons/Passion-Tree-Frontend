import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/popups/student/rating_section.dart';

class RatingPopup extends StatelessWidget {
  final String pathName;
  final VoidCallback onSubmit;

  const RatingPopup({
    super.key,
    required this.pathName,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 360,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Text('Path:$pathName', style: AppPixelTypography.h3),

              const SizedBox(height: 20),

              // ===== SECTION 1 =====
              RatingSection(
                title: 'Content Quality',
                subtitle: 'คุณภาพของเนื้อหา',
              ),

              const SizedBox(height: 24),

              // ===== SECTION 2 =====
              RatingSection(
                title: 'Instructor & Delivery',
                subtitle: 'คุณภาพของการสอน',
              ),

              const SizedBox(height: 24),

              // ===== SECTION 3 =====
              RatingSection(
                title: 'Overall Experience',
                subtitle: 'ประสบการณ์โดยรวม',
              ),

              const SizedBox(height: 28),

              // ===== BUTTONS =====
              SaveCancel(
                saveText: 'Submit',
                cancelText: 'Cancel',
                onCancel: () => Navigator.pop(context),
                onSave: () {
                  Navigator.pop(context);
                  onSubmit();
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
    required String pathName,
    required VoidCallback onSubmit,
  }) {
    showDialog(
      context: context,
      builder: (_) => RatingPopup(pathName: pathName, onSubmit: onSubmit),
    );
  }
}
