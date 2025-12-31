import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'button_enums.dart';

class AppButton extends StatefulWidget {
  final AppButtonVariant variant;
  final AppButtonSize size;
  final String? text;
  final Widget? icon;
  final VoidCallback onPressed;

  const AppButton({
    super.key,
    required this.variant,
    required this.onPressed,
    this.text,
    this.icon,
    this.size = AppButtonSize.large,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  static const double _pixel = 4;
  static const double _horizontalPadding = 40; // 20 + 20
  static const double _iconSize = 16;
  static const double _iconSpacing = 16;

  // ===================================================
  // Build
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final offset = _pressed ? 2.0 : 4.0;

    
    final TextStyle buttonTextStyle = AppPixelTypography.smallTitle.copyWith(
      color: scheme.onPrimary,
    );

    final double buttonWidth = switch (widget.variant) {
      AppButtonVariant.iconOnly => _iconOnlyWidth(),
      AppButtonVariant.textWithIcon => _calculateWidthFromTextAndIcon(
        buttonTextStyle,
      ),
      AppButtonVariant.text => _calculateWidthFromText(buttonTextStyle),
    };

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: SizedBox(
        width: buttonWidth,
        height: _height() + offset,
        child: Stack(
          children: [
            Positioned(
              top: offset,
              child: _buildPixelLayer(
                width: buttonWidth,
                color: scheme.onSurface,
                child: const SizedBox(),
              ),
            ),
            _buildPixelLayer(
              width: buttonWidth,
              color: scheme.primary,
              borderColor: scheme.onSurface,
              child: Center(child: _buildContent(buttonTextStyle)),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================
  // Pixel Layer
  // ===================================================
  Widget _buildPixelLayer({
    required double width,
    required Color color,
    Color? borderColor,
    required Widget child,
  }) {
    return SizedBox(
      width: width,
      height: _height(),
      child: Stack(
        children: [
          Positioned(
            left: 4,
            top: 4,
            right: 4,
            bottom: 4,
            child: Container(color: color),
          ),
          if (borderColor != null)
            IgnorePointer(
              child: CustomPaint(
                size: Size(width, _height()),
                painter: _PixelBorderPainter(color: borderColor, p: 4),
              ),
            ),
          child,
        ],
      ),
    );
  }

  // ===================================================
  // Content
  // ===================================================
  Widget _buildContent(TextStyle textStyle) {
    switch (widget.variant) {
      case AppButtonVariant.text:
        return Text(widget.text ?? '', style: textStyle);

      case AppButtonVariant.textWithIcon:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.text ?? '', style: textStyle),
            const SizedBox(width: _iconSpacing),
            widget.icon ?? const SizedBox(),
          ],
        );

      case AppButtonVariant.iconOnly:
        return widget.icon ?? const SizedBox();
    }
  }

  // ===================================================
  // Size & Width Calculation
  // ===================================================
  double _height() => 40;
  double _iconOnlyWidth() => 64;

  double _calculateWidthFromText(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text ?? '', style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final rawWidth = painter.width + _horizontalPadding;
    return (rawWidth / _pixel).ceil() * _pixel;
  }

  double _calculateWidthFromTextAndIcon(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text ?? '', style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final rawWidth =
        painter.width + _iconSize + _iconSpacing + _horizontalPadding;

    return (rawWidth / _pixel).ceil() * _pixel;
  }
}

// ===================================================
// Pixel Capsule Border Painter (ไม่ยุ่ง Typography)
// ===================================================
class _PixelBorderPainter extends CustomPainter {
  final Color color;
  final double p;

  _PixelBorderPainter({required this.color, this.p = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;

    for (double x = p * 3; x <= w - p * 4; x += p) {
      canvas.drawRect(Rect.fromLTWH(x, 0, p, p), paint);
      canvas.drawRect(Rect.fromLTWH(x, h - p, p, p), paint);
    }

    for (double y = p * 3; y <= h - p * 4; y += p) {
      canvas.drawRect(Rect.fromLTWH(0, y, p, p), paint);
      canvas.drawRect(Rect.fromLTWH(w - p, y, p, p), paint);
    }

    // corners
    canvas.drawRect(Rect.fromLTWH(p, p, p, p), paint);
    canvas.drawRect(Rect.fromLTWH(p * 2, p, p, p), paint);
    canvas.drawRect(Rect.fromLTWH(p, p * 2, p, p), paint);

    canvas.drawRect(Rect.fromLTWH(w - p * 2, p, p, p), paint);
    canvas.drawRect(Rect.fromLTWH(w - p * 3, p, p, p), paint);
    canvas.drawRect(Rect.fromLTWH(w - p * 2, p * 2, p, p), paint);

    canvas.drawRect(Rect.fromLTWH(p, h - p * 2, p, p), paint);
    canvas.drawRect(Rect.fromLTWH(p * 2, h - p * 2, p, p), paint);
    canvas.drawRect(Rect.fromLTWH(p, h - p * 3, p, p), paint);

    canvas.drawRect(Rect.fromLTWH(w - p * 2, h - p * 2, p, p), paint);
    canvas.drawRect(Rect.fromLTWH(w - p * 3, h - p * 2, p, p), paint);
    canvas.drawRect(Rect.fromLTWH(w - p * 2, h - p * 3, p, p), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
