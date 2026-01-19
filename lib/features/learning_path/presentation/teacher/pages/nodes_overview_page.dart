
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_preview_card.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';

class NodesOverviewPage extends StatelessWidget {
  const NodesOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: const [
            // 1️⃣ Scrollable + draggable nodesb
            Positioned.fill(child: NodeCanvas()),

            // 2️⃣ Fixed header
            Positioned(top: 0, left: 0, right: 0, child: HeaderBar()),

            // 3️⃣ Fixed bottom actions
            Positioned(bottom: 0, left: 0, right: 0, child: BottomActionBar()),
          ],
        ),
      ),
    );
  }
}
