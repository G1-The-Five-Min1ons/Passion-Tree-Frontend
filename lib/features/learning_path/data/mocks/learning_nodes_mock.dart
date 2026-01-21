import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_node.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';

final mockLearningNodes = [
  LearningNode(title: 'Cell', state: LearningNodeState.active),
  LearningNode(title: 'Cell Structure', state: LearningNodeState.active, isCurrent: true),
  LearningNode(title: 'DNA', state: LearningNodeState.locked),
  LearningNode(title: 'Protein', state: LearningNodeState.locked),
  LearningNode(title: 'Metabolism', state: LearningNodeState.locked),
];
