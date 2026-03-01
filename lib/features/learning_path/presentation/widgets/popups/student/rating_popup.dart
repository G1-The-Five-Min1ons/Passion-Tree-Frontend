import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/popups/student/rating_section.dart';

class RatingPopup extends StatefulWidget {
  final String pathName;
  final VoidCallback onSubmit;

  const RatingPopup({
    super.key,
    required this.pathName,
    required this.onSubmit,
  });

  @override
  State<RatingPopup> createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup> {
  int? _contentQualityRating;
  int? _instructorRating;
  int? _overallRating;
  String? _errorMessage;

  void _handleSubmit() {
    // Check if all ratings are selected
    final unratedSections = <String>[];
    
    if (_contentQualityRating == null) {
      unratedSections.add('Content Quality');
    }
    if (_instructorRating == null) {
      unratedSections.add('Instructor & Delivery');
    }
    if (_overallRating == null) {
      unratedSections.add('Overall Experience');
    }

    // If not all ratings selected, show error message
    if (unratedSections.isNotEmpty) {
      setState(() {
        _errorMessage = unratedSections.length == 1
            ? 'Please rate ${unratedSections[0]}'
            : 'Please rate all sections';
      });
      return;
    }

    // All ratings selected, proceed with submit
    setState(() {
      _errorMessage = null;
    });
    widget.onSubmit();
  }

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
              Text('Path:${widget.pathName}', style: AppPixelTypography.h3),

              const SizedBox(height: 20),

              // ===== SECTION 1 =====
              RatingSection(
                title: 'Content Quality',
                subtitle: 'คุณภาพของเนื้อหา',
                initialValue: _contentQualityRating,
                onRatingChanged: (value) {
                  setState(() {
                    _contentQualityRating = value;
                    _errorMessage = null; // Clear error when user selects
                  });
                },
              ),

              const SizedBox(height: 24),

              // ===== SECTION 2 =====
              RatingSection(
                title: 'Instructor & Delivery',
                subtitle: 'คุณภาพของการสอน',
                initialValue: _instructorRating,
                onRatingChanged: (value) {
                  setState(() {
                    _instructorRating = value;
                    _errorMessage = null; // Clear error when user selects
                  });
                },
              ),

              const SizedBox(height: 24),

              // ===== SECTION 3 =====
              RatingSection(
                title: 'Overall Experience',
                subtitle: 'ประสบการณ์โดยรวม',
                initialValue: _overallRating,
                onRatingChanged: (value) {
                  setState(() {
                    _overallRating = value;
                    _errorMessage = null; // Clear error when user selects
                  });
                },
              ),

              const SizedBox(height: 28),

              // ===== ERROR MESSAGE =====
              if (_errorMessage != null)
                Center(
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.subtitleRegular.copyWith(
                      color: colors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              if (_errorMessage != null) const SizedBox(height: 16),

              // ===== BUTTONS =====
              SaveCancel(
                saveText: 'Submit',
                cancelText: 'Cancel',
                onCancel: () => Navigator.pop(context),
                onSave: _handleSubmit,
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
