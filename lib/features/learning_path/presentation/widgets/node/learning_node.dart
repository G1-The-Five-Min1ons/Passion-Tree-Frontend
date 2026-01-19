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
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';

import 'package:flutter/material.dart';
import 'node_state.dart';
import 'node_asset.dart';

class LearningNode extends StatelessWidget {
  final LearningNodeState state;
  final VoidCallback? onTap;

  const LearningNode({super.key, required this.state, this.onTap});

  bool get _isActive => state == LearningNodeState.active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isActive ? onTap : null,
      child: Opacity(
        opacity: _isActive ? 1.0 : 0.5,
        child: Image.asset(NodeAsset.image(state), width: 64, height: 64),
      ),
    );
  }
}
