import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';

class LearningNode {
  final String title;
  final LearningNodeState state;
  final bool isCurrent;

  const LearningNode({
    required this.title,
    required this.state,
    this.isCurrent = false,
  });

  LearningNode copyWith({
    String? title,
    LearningNodeState? state,
    bool? isCurrent,
  }) {
    return LearningNode(
      title: title ?? this.title,
      state: state ?? this.state,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}
