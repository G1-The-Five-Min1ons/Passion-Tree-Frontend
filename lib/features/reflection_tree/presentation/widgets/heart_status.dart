import 'package:flutter/material.dart';

class HeartStatus extends StatelessWidget{
    final int count;
    final double size;

    const HeartStatus ({
        super.key,
        this.count = 5,
        this.size = 24,
    });

    @override
    Widget build(BuildContext context) {
        return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:  [
                ...List.generate(count, (index) {
                return Padding (
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Image.asset(
                        'assets/icons/Pixel_heart.png',
                        width: size,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        isAntiAlias: false,
                    ),
                );
            }),
                GestureDetector(
                onTap: () {},
                child: Transform.translate(
                    offset: const Offset(0, 5),
                child: Image.asset(
                    'assets/icons/Info.png',
                    width: 36,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                    isAntiAlias: false,
                        ),
                    ),
                ),
            ],
        );
    }
}