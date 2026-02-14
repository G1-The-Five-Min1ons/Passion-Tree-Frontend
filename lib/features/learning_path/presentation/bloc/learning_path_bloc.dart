import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';

class LearningPathBloc extends Bloc<LearningPathEvent, LearningPathState> {
  final GetAllLearningPaths getAllLearningPaths;
  final GetLearningPathStatus getLearningPathStatus;

  LearningPathBloc(this.getAllLearningPaths, this.getLearningPathStatus)
    : super(LearningPathInitial()) {
    
    ///  FETCH ALL LEARNING PATHS
    
    on<FetchLearningPaths>((event, emit) async {
      emit(LearningPathLoading());

      try {
        final paths = await getAllLearningPaths();
        emit(LearningPathLoaded(paths));
      } catch (e) {
        emit(LearningPathError(e.toString()));
      }
    });

    
    /// FETCH STATUS (WITH PROGRESS)
    
    on<FetchLearningPathStatus>((event, emit) async {
      emit(LearningPathLoading());

      try {
        final result = await getLearningPathStatus(event.userId);

        emit(LearningPathStatusLoaded(result));
      } catch (e) {
        emit(LearningPathError(e.toString()));
      }
    });
  }
}
