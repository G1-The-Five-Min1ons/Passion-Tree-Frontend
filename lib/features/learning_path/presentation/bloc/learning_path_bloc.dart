import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/nodes_for_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/node_detail_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/start_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/complete_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';

class LearningPathBloc extends Bloc<LearningPathEvent, LearningPathState> {
  final GetAllLearningPaths getAllLearningPaths;
  final GetLearningPathStatus getLearningPathStatus;
  final GetNodesForPath getNodesForPath;
  final GetNodeDetail getNodeDetail;
  final StartNode startNode;
  final CompleteNode completeNode;

  LearningPathBloc(
    this.getAllLearningPaths,
    this.getLearningPathStatus,
    this.getNodesForPath,
    this.getNodeDetail,
    this.startNode,
    this.completeNode,
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
        final nodes = await getNodesForPath(event.pathId, event.userId);
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
        final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
        emit(NodeDetailLoaded(nodeDetail));
      } catch (e) {
        emit(LearningPathError(e.toString()));
      }
    });

    /// START NODE
    
    on<StartNodeEvent>((event, emit) async {
      try {
        await startNode(event.nodeId, event.userId);
        // Optionally refetch node detail to get updated status
        final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
        emit(NodeDetailLoaded(nodeDetail));
      } catch (e) {
        emit(LearningPathError(e.toString()));
      }
    });

    /// COMPLETE NODE
    
    on<CompleteNodeEvent>((event, emit) async {
      try {
        await completeNode(event.nodeId, event.userId);
        // Optionally refetch node detail to get updated status
        final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
        emit(NodeDetailLoaded(nodeDetail));
      } catch (e) {
        emit(LearningPathError(e.toString()));
      }
    });
  }
}
