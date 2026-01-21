import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_node.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/node_state.dart';

final mockLearningNodes = [
  LearningNode(title: 'Cell', state: LearningNodeState.locked),
  LearningNode(title: 'Cell Structure', state: LearningNodeState.locked, isCurrent: true),//เขียนไว้เวลาจะต้องการให้มีลุกศรชี้บนหัวโหนด
  LearningNode(title: 'DNA', state: LearningNodeState.locked),
  LearningNode(title: 'Protein', state: LearningNodeState.active),
  LearningNode(title: 'Metabolism', state: LearningNodeState.active),
];
