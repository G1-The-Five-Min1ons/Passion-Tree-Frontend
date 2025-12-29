import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class _RadioButtonPainter extends CustomPainter {
  final Color borderColor;
  final Color activeColor;
  final Color surfaceColor;
  final bool isSelected;
  final int index;
  final TextStyle textStyle;

  _RadioButtonPainter({
    required this.borderColor,
    required this.activeColor, 
    required this.surfaceColor, 
    required this.isSelected,
    required this.index,
    required this.textStyle,
    }); 

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);

    // วาดวงกลมนอก
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
      canvas.drawCircle(center, w / 2.1, paint);

    // วาดวงกลมใน (เล็กกว่า)
    final innerPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w / 2.4, innerPaint);

    if(isSelected) {
      final selectedPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, w / 3.3, selectedPaint);
    } else {
      final textPainter = TextPainter(
          text : TextSpan(
            text: index.toString(),
            style: textStyle,
            ),
          textDirection : TextDirection.ltr,
        );

      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadioButtonPainter oldDelegate) => 
      oldDelegate.isSelected != isSelected || oldDelegate.index != index;
}

class PixelRadioButton extends StatelessWidget {
  final bool isSelected;
  final Color? borderColor;
  final int index;

  static const double fixedSize = 32.0;

  const PixelRadioButton({
    super.key,
    required this.isSelected,
    this.borderColor,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle radioTextStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    final Color themeSurface = Theme.of(context).colorScheme.surface;
    final Color themeOnSurface = Theme.of(context).colorScheme.onSurface;
    final Color themePrimary = Theme.of(context).colorScheme.primary;


    return CustomPaint(
      size: const Size (fixedSize, fixedSize),
      painter: _RadioButtonPainter(
        borderColor: AppColors.scale,
        activeColor: themePrimary,
        surfaceColor: themeSurface,
        isSelected: isSelected,
        index: index,
        textStyle: radioTextStyle.copyWith(color: themeOnSurface,),
      ),
    );
  }
}

class PixelRadioGroup extends StatefulWidget {
  final int count;
  final int initialValue;
  final ValueChanged<int> onSelected;

  const PixelRadioGroup({
    super.key,
    this.count = 5,
    this.initialValue = 0,
    required this.onSelected,
  });

  @override
  State<PixelRadioGroup> createState() => _PixelRadioGroupState();
}

class _PixelRadioGroupState extends State<PixelRadioGroup> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.count, (index) {
        int radioValue = index + 1; 

        return Row (
          //padding: const EdgeInsets.symmetric(horizontal: 14.0),
          children: [ 
            GestureDetector(
              onTap: () {
                setState(() => _currentValue = radioValue);
                widget.onSelected(radioValue);
              },
              child: PixelRadioButton(
                index: radioValue,
                isSelected: _currentValue == radioValue,
              ),
            ),
            if (index < widget.count - 1)
              Container(
              width: 20.0, 
              height: 2.0, 
              margin: const EdgeInsets.symmetric(horizontal: 4.0), 
              decoration: BoxDecoration(
                color: AppColors.scale, // สีของเส้น
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ],
        );
      }),
    );
  }
}

//---------------------- วิธีเรียกใช้ ----------------------//
//int _score = 0; --- ต้องกำหนดไว้ด้วย เพื่อให้เก็บค่าที่เลือกลง db แต่ตอนนี้ยังไม่มี logic
/* PixelRadioGroup(
            onSelected: (value) {
              setState(() {
                _score = value;
              });
            }
          ),
*/