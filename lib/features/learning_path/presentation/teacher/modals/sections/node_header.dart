import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';

class NodeModalHeader extends StatelessWidget {
  const NodeModalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ===== CLOSE BUTTON (TOP RIGHT – PIXEL PERFECT) =====
        Positioned(
          top: -8, // ดันขึ้นให้ชิดขอบกรอบ
          right: -8, //ชิดขอบขวา
          child: IconTheme(
            data: const IconThemeData(size: 30),
            child: const CloseIcon(),
          ),

        ),

        // ===== CONTENT =====
        Padding(
          padding: const EdgeInsets.only(
            top: 30, // เว้นให้ title ไม่ชนปุ่ม
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Node',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppPixelTypography.title,
              ),

              const SizedBox(height: 20),

              Center(
                child: Image.asset(
                  'assets/images/learning_path/node/node_active.png',
                  width: 90,
                  height: 90,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

