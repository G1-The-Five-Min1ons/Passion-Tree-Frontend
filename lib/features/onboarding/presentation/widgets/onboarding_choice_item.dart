import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class OnboardingChoiceItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const OnboardingChoiceItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<OnboardingChoiceItem> createState() => _OnboardingChoiceItemState();
}

class _OnboardingChoiceItemState extends State<OnboardingChoiceItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.94), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textColor = widget.isSelected ? colors.primary : colors.onSurface;
    final borderColor = widget.isSelected ? colors.onPrimary : AppColors.cardBorder;
    final fillColor = widget.isSelected ? colors.onPrimary : colors.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
          child: PixelBorderContainer(
            width: double.infinity,
            height: 72,
            borderColor: borderColor,
            fillColor: fillColor,
            child: Center(
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: AppTypography.titleSemiBold.copyWith(
                  fontSize: 18,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
