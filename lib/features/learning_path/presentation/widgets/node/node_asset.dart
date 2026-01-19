import 'node_state.dart';


class NodeAsset {
  static String image(LearningNodeState state) {
    switch (state) {
      case LearningNodeState.active:
        return 'assets/images/learning_path/node/node_active.png';
      case LearningNodeState.locked:
        return 'assets/images/learning_path/node/node_locked.png';
      
    }
  }
}
