import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/arrow_button.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:material_symbols_icons/symbols.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppBarWidget({
    super.key, 
    required this.title, 
    this.showBackButton = false,
    this.onBackPressed,
    });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = AppColors.bar;
    final Color contentColor = Theme.of(context).colorScheme.onPrimary;

    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      color : backgroundColor.withValues(alpha: 0.6), 
      child : SafeArea( //ไม่ให้ทับเนื้อหาสำคัญเช่น เวลา แบตเตอรี่
        bottom : false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showBackButton)
            Align(
              alignment: Alignment.centerLeft,
              child: ArrowButton(
                    direction: ArrowDirection.left,
                    onPressed: () {
                        if (onBackPressed != null) {
                          onBackPressed!();
                        } else if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),

            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//---------------------- วิธีเรียกใช้ ----------------------//
/* appBar: AppBarWidget(
  title: "Home",
  showBackButton: false, // ถ้าอยากให้มีปุ่มกลับให้ลบบรรทัดนี้ออก
),
*/