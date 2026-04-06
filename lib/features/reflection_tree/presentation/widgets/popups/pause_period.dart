import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class PausePeriod extends StatelessWidget{
  final String? pauseFrom;
  final String? pauseTo;

  const PausePeriod({super.key, this.pauseFrom, this.pauseTo});

  static void show(
    BuildContext context, {
    String? pauseFrom,
    String? pauseTo,
  }) {
    showDialog(
      context: context,
      builder: (context) =>
          PausePeriod(pauseFrom: pauseFrom, pauseTo: pauseTo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 0),
      child: SizedBox(
        width: 280,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 0, top: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      //idth: double.infinity,
                      child: Text(
                        'Tree will pause',
                        textAlign: TextAlign.center,
                        style: AppPixelTypography.smallTitle,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'From :',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          pauseFrom ?? '-',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'To :',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          pauseTo ?? '-',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                right: -22,
                top: -22,
                child: IconTheme(
                  data: const IconThemeData(size: 24),
                  child: CloseIcon(
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}