import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';

import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_asset.dart';

// ไฟลนี้ค่อยเอาไว้ใช้ ถ้า Node เริ่มมี behavior ของตัวเอง → ทำ Node ของ feature
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
