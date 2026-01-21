import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';

class LearningNode {
  final String title;
  final LearningNodeState state;
  final bool isCurrent; // เพิ่มตัวแปร isCurrent เกี่ยวกะปุ่มบนหัวโหนด

  LearningNode({
    required this.title,
    required this.state,
    this.isCurrent = false,
  });
}

