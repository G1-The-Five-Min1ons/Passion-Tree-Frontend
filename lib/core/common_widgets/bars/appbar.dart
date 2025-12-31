import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const AppBarWidget({
    super.key, 
    required this.title, 
    this.showBackButton = false});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).colorScheme.primary;
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
              child: IconButton(
                icon: Text(
                  "<", // mock ไว้รอปุ่มจริง
                  style: TextStyle(
                    color: contentColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                    // เช็คว่ากดกลับได้มั้ย ถ้าได้ให้กลับ
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: contentColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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