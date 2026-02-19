import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/nodes_for_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/node_detail_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/start_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/complete_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/delete_learning_path_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';

class LearningPathBloc extends Bloc<LearningPathEvent, LearningPathState> {
  final GetAllLearningPaths getAllLearningPaths;
  final GetLearningPathStatus getLearningPathStatus;
  final GetNodesForPath getNodesForPath;
  final GetNodeDetail getNodeDetail;
  final StartNode startNode;
  final CompleteNode completeNode;
  final DeleteLearningPath deleteLearningPath;

  LearningPathBloc(
    this.getAllLearningPaths,
    this.getLearningPathStatus,
    this.getNodesForPath,
    this.getNodeDetail,
    this.startNode,
    this.completeNode,
    this.deleteLearningPath,
  ) : super(LearningPathInitial()) {
    
    ///  FETCH ALL LEARNING PATHS
    
    on<FetchLearningPaths>((event, emit) async {
      debugPrint('[BLoC] FetchLearningPaths event received');
      emit(LearningPathLoading());

      try {
        debugPrint('Fetching all learning paths...');
        final paths = await getAllLearningPaths();
        debugPrint('[BLoC] Successfully loaded ${paths.length} paths');
        emit(LearningPathLoaded(paths));
      } catch (e) {
        debugPrint('[BLoC] Error fetching paths: $e');
        emit(LearningPathError(e.toString()));
      }
    });

    
    /// FETCH STATUS (WITH PROGRESS)
    
    on<FetchLearningPathStatus>((event, emit) async {
      debugPrint('[BLoC] FetchLearningPathStatus event received');
      debugPrint('User ID: ${event.userId}');
      emit(LearningPathLoading());

      try {
        debugPrint('Fetching learning path status...');
        final result = await getLearningPathStatus(event.userId);
        debugPrint('[BLoC] Successfully loaded ${result.length} enrolled paths');
        emit(LearningPathStatusLoaded(result));
      } catch (e) {
        debugPrint('[BLoC] Error fetching status: $e');
        emit(LearningPathError(e.toString()));
      }
    });

    /// FETCH OVERVIEW (ALL PATHS + ENROLLED PATHS)
    
    on<FetchLearningPathOverview>((event, emit) async {
      debugPrint('[BLoC] FetchLearningPathOverview event received');
      debugPrint('User ID: ${event.userId ?? "Guest (no login)"}');
      emit(LearningPathLoading());

      try {
        debugPrint('Fetching all paths...');
        final allPaths = await getAllLearningPaths();
        debugPrint('Loaded ${allPaths.length} all paths');
        
        final enrolledPaths = event.userId != null
            ? await getLearningPathStatus.repository.getEnrolledPaths(event.userId!)
            : <EnrolledLearningPath>[];
        debugPrint('Loaded ${enrolledPaths.length} enrolled paths');

        emit(LearningPathOverviewLoaded(
          allPaths: allPaths,
          enrolledPaths: enrolledPaths,
        ));
        debugPrint('[BLoC] Overview loaded successfully');
      } catch (e) {
        debugPrint('[BLoC] Error fetching overview: $e');
        emit(LearningPathError(e.toString()));
      }
    });

    /// FETCH NODES FOR PATH
    
    on<FetchNodesForPath>((event, emit) async {
      debugPrint('[BLoC] FetchNodesForPath event received');
      debugPrint('Path ID: ${event.pathId}');
      debugPrint('User ID: ${event.userId}');
      emit(LearningPathLoading());

      try {
        debugPrint('Fetching nodes for path...');
        final nodes = await getNodesForPath(event.pathId, event.userId);
        debugPrint('[BLoC] Successfully loaded ${nodes.length} nodes');
        emit(NodesLoaded(
          pathId: event.pathId,
          nodes: nodes,
        ));
      } catch (e) {
        debugPrint('[BLoC] Error fetching nodes: $e');
        emit(LearningPathError(e.toString()));
      }
    });

    /// FETCH NODE DETAIL
    
    on<FetchNodeDetail>((event, emit) async {
      debugPrint('[BLoC] FetchNodeDetail event received');
      debugPrint('Node ID: ${event.nodeId}');
      debugPrint('User ID: ${event.userId}');
      emit(LearningPathLoading());

      try {
        debugPrint('Fetching node detail...');
        final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
        debugPrint('[BLoC] Successfully loaded node detail: ${nodeDetail.title}');
        emit(NodeDetailLoaded(nodeDetail));
      } catch (e) {
        debugPrint('[BLoC] Error fetching node detail: $e');
        emit(LearningPathError(e.toString()));
      }
    });

    /// START NODE
    
    on<StartNodeEvent>((event, emit) async {
      debugPrint('[BLoC] StartNodeEvent received');
      debugPrint('Node ID: ${event.nodeId}');
      debugPrint('User ID: ${event.userId}');
      
      try {
        debugPrint('Starting node...');
        await startNode(event.nodeId, event.userId);
        debugPrint('Node started, fetching updated detail...');
        // Optionally refetch node detail to get updated status
        final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
        debugPrint('[BLoC] Node started successfully');
        emit(NodeDetailLoaded(nodeDetail));
      } catch (e) {
        debugPrint('[BLoC] Error starting node: $e');
        emit(LearningPathError(e.toString()));
      }
    });

    /// COMPLETE NODE
    
    on<CompleteNodeEvent>((event, emit) async {
      debugPrint('[BLoC] CompleteNodeEvent received');
      debugPrint('Node ID: ${event.nodeId}');
      debugPrint('User ID: ${event.userId}');
      
      try {
        debugPrint('Completing node...');
        await completeNode(event.nodeId, event.userId);
        debugPrint('Node completed, fetching updated detail...');
        // Optionally refetch node detail to get updated status
        final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
        debugPrint('[BLoC] Node completed successfully');
        emit(NodeDetailLoaded(nodeDetail));
      } catch (e) {
        debugPrint('[BLoC] Error completing node: $e');
        emit(LearningPathError(e.toString()));
      }
    });

    /// DELETE LEARNING PATH
    
    on<DeleteLearningPathEvent>((event, emit) async {
      debugPrint('[BLoC] DeleteLearningPathEvent received');
      debugPrint('Path ID: ${event.pathId}');
      
      try {
        debugPrint('Deleting learning path...');
        await deleteLearningPath(event.pathId);
        debugPrint('[BLoC] Learning path deleted successfully');
        
        // Refresh overview if userId is provided
        if (event.userId != null) {
          debugPrint('Refreshing overview...');
          final allPaths = await getAllLearningPaths();
          final enrolledPaths = await getLearningPathStatus.repository.getEnrolledPaths(event.userId!);
          
          emit(LearningPathOverviewLoaded(
            allPaths: allPaths,
            enrolledPaths: enrolledPaths,
          ));
        } else {
          emit(LearningPathDeleted('Learning path deleted successfully'));
        }
      } catch (e) {
        debugPrint('[BLoC] Error deleting learning path: $e');
        emit(LearningPathError(e.toString()));
      }
    });
  }
}
