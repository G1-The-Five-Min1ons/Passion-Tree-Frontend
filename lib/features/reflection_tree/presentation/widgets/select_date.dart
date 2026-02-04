import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class PixelCalendarDialog extends StatefulWidget {
  const PixelCalendarDialog({super.key});

  static Future<List<DateTime?>?> show(BuildContext context) {
    return showDialog<List<DateTime?>>(
      context: context,
      builder: (context) => const PixelCalendarDialog(),
    );
  }

  @override
  State<PixelCalendarDialog> createState() => _PixelCalendarDialogState();
}

class _PixelCalendarDialogState extends State<PixelCalendarDialog> {
  DateTime viewingMonth = DateTime.now();
  DateTime? rangeStart;
  DateTime? rangeEnd;
  final List<String> weekDays = ['S', 'M', 'T', 'W', 'TH', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    int firstDayOffset = DateTime(viewingMonth.year, viewingMonth.month, 1).weekday % 7;
    int daysInMonth = DateTime(viewingMonth.year, viewingMonth.month + 1, 0).day;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 240,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavButton(Icons.chevron_left, () {
                    setState(() => viewingMonth = DateTime(viewingMonth.year, viewingMonth.month - 1));
                  }),
                  Text(
                    "${_getMonthName(viewingMonth.month)} ${viewingMonth.year}",
                    style: AppTypography.titleSemiBold.copyWith(fontSize: 14),
                  ),
                  _buildNavButton(Icons.chevron_right, () {
                    setState(() => viewingMonth = DateTime(viewingMonth.year, viewingMonth.month + 1));
                  }),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.scale),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weekDays.map((day) => Expanded(
                  child: Center(
                    child: Text(day, style: AppTypography.smallBodySemiBold.copyWith(color: AppColors.textDisabled)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                ),
                itemCount: daysInMonth + firstDayOffset,
                itemBuilder: (context, index) {
                  if (index < firstDayOffset) return const SizedBox.shrink();

                  int day = index - firstDayOffset + 1;
                  DateTime dateAtSlot = DateTime(viewingMonth.year, viewingMonth.month, day);
                  
                  bool isStart = rangeStart != null && dateAtSlot.isAtSameMomentAs(rangeStart!);
                  bool isEnd = rangeEnd != null && dateAtSlot.isAtSameMomentAs(rangeEnd!);
                  bool isInRange = rangeStart != null && rangeEnd != null && 
                                   dateAtSlot.isAfter(rangeStart!) && dateAtSlot.isBefore(rangeEnd!);

                  return GestureDetector(
                    onTap: () => _handleDateTap(dateAtSlot),
                    child: Stack(
                      children: [
                        if (isInRange || isStart || isEnd)
                          Positioned.fill(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4), 
                              decoration: BoxDecoration(
                                color: AppColors.primaryBrand.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.only(
                                  topLeft: isStart ? const Radius.circular(16) : Radius.zero,
                                  bottomLeft: isStart ? const Radius.circular(16) : Radius.zero,
                                  topRight: isEnd ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isEnd ? const Radius.circular(16) : Radius.zero,
                                ),
                              ),
                            ),
                          ),
                        

                        Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isStart || isEnd) ? AppColors.primaryBrand : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                "$day",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: (isStart || isEnd) ? AppColors.surface : AppColors.textPrimary,
                                  fontWeight: (isStart || isEnd) ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDateTap(DateTime date) {
    setState(() {
      if (rangeStart == null || (rangeStart != null && rangeEnd != null)) {
        rangeStart = date;
        rangeEnd = null;
      } else if (date.isBefore(rangeStart!)) {
        rangeStart = date;
      } else {
        rangeEnd = date;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) Navigator.pop(context, [rangeStart, rangeEnd]);
        });
      }
    });
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(color: AppColors.primaryBrand, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.surface, size: 18),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return months[month - 1];
  }
}