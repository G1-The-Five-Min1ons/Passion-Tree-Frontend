import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/how_to_use_popup.dart';

class HeartStatus extends StatelessWidget{
    final int count;
    final int currentCount;
    final double size;

    const HeartStatus ({
        super.key,
        this.count = 5,
        this.currentCount = 3,
        this.size = 24,
    });

    @override
    Widget build(BuildContext context) {
        return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:  [
              ...List.generate(count, (index) {
                final String iconPath = index < currentCount
                ? 'assets/icons/Pixel_heart.png'
                : 'assets/icons/heart-gray.png';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Image.asset(
                    iconPath,
                    width: size,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    isAntiAlias: false,
                  ),
                );
              }),
                GestureDetector(
                onTap: () {
                  HowToUsePopup.show(context);
                },
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