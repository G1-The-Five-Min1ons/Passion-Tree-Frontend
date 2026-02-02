import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/select_date.dart'; // ตรวจสอบ path นี้

class SelectPausePeriodPopup extends StatefulWidget {
  const SelectPausePeriodPopup({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SelectPausePeriodPopup(),
    );
  }

  @override
  State<SelectPausePeriodPopup> createState() => _SelectPausePeriodPopupState();
}

class _SelectPausePeriodPopupState extends State<SelectPausePeriodPopup> {
  DateTime? fromDate;
  DateTime? toDate;

  void _openRangePicker() async {
    final List<DateTime?>? pickedRange = await PixelCalendarDialog.show(context);

    if (pickedRange != null && pickedRange.length == 2) {
      setState(() {
        fromDate = pickedRange[0];
        toDate = pickedRange[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 240,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Date Period", style: AppPixelTypography.smallTitle),
              const SizedBox(height: 30),
              
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text("From :", style: AppTypography.subtitleRegular),
                  ),
                  Expanded(
                    child: _buildDateInput(
                      date: fromDate,
                      onTap: _openRangePicker,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text("To :", style: AppTypography.subtitleRegular),
                  ),
                  Expanded(
                    child: _buildDateInput(
                      date: toDate,
                      onTap: _openRangePicker,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              SaveCancel(
                saveText: '3',
                saveIcon: const PixelIcon('assets/icons/Pixel_heart.png'),
                onCancel: () => Navigator.pop(context),
                onSave: (fromDate != null && toDate != null) 
                  ? () { 
                      debugPrint("Save: $fromDate to $toDate");
                      Navigator.pop(context); 
                    } 
                  : null, 
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInput({DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: PixelBorderContainer(
        pixelSize: 2,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null 
                  ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
                  : "DD/MM/YYYY",
              style: AppTypography.subtitleRegular.copyWith(
                fontSize: 11,
                color: date != null ? AppColors.textPrimary : AppColors.textDisabled,
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}