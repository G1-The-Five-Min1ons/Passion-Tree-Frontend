import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/nodes_for_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/get_node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';

class LearningPathBloc extends Bloc<LearningPathEvent, LearningPathState> {
  final GetAllLearningPaths getAllLearningPaths;
  final GetLearningPathStatus getLearningPathStatus;
  final GetNodesForPath getNodesForPath;
  final GetNodeDetail getNodeDetail;

  LearningPathBloc(
    this.getAllLearningPaths,
    this.getLearningPathStatus,
    this.getNodesForPath,
    this.getNodeDetail,
  ) : super(LearningPathInitial()) {
    
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

    /// FETCH OVERVIEW (ALL PATHS + ENROLLED PATHS)
    
    on<FetchLearningPathOverview>((event, emit) async {
      emit(LearningPathLoading());

      try {
        final allPaths = await getAllLearningPaths();
        
        final enrolledPaths = event.userId != null
            ? await getLearningPathStatus.repository.getEnrolledPaths(event.userId!)
            : <EnrolledLearningPath>[];

        emit(LearningPathOverviewLoaded(
          allPaths: allPaths,
          enrolledPaths: enrolledPaths,
        ));
      } catch (e) {
        emit(LearningPathError(e.toString()));
      }
    });

    /// FETCH NODES FOR PATH
    
    on<FetchNodesForPath>((event, emit) async {
      emit(LearningPathLoading());

      try {
        final nodes = await getNodesForPath(event.pathId);
        emit(NodesLoaded(
          pathId: event.pathId,
          nodes: nodes,
        ));
      } catch (e) {
        emit(LearningPathError(e.toString()));
      }
    });

    /// FETCH NODE DETAIL
    
    on<FetchNodeDetail>((event, emit) async {
      emit(LearningPathLoading());

      try {
        final nodeDetail = await getNodeDetail(event.nodeId);
        emit(NodeDetailLoaded(nodeDetail));
      } catch (e) {
        emit(LearningPathError(e.toString()));
      }
    });
  }
}
