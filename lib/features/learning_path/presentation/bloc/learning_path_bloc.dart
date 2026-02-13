import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_usecases.dart';

class LearningPathBloc extends Bloc<LearningPathEvent, LearningPathState> {
  final GetAllLearningPaths getAllLearningPaths;

  LearningPathBloc(this.getAllLearningPaths) : super(LearningPathInitial()) {
    on<FetchLearningPaths>((event, emit) async {
      emit(LearningPathLoading());

      try {
        final paths = await getAllLearningPaths();
        emit(LearningPathLoaded(paths));
      } catch (e) {
        emit(LearningPathError(e.toString()));
      }
    });
  }
}
