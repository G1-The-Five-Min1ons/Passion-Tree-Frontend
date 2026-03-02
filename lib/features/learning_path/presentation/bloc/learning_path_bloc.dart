import 'package:passion_tree_frontend/core/network/log_handler.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/learning_path_status.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/nodes_for_path_usecases.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/node_detail_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/enroll_path_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/start_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/complete_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/delete_learning_path_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';

class LearningPathBloc extends Bloc<LearningPathEvent, LearningPathState> {
  final GetAllLearningPaths getAllLearningPaths;
  final GetLearningPathStatus getLearningPathStatus;
  final GetNodesForPath getNodesForPath;
  final GetNodeDetail getNodeDetail;
  final EnrollPath enrollPath;
  final StartNode startNode;
  final CompleteNode completeNode;
  final DeleteLearningPath deleteLearningPath;

  LearningPathBloc(
    this.getAllLearningPaths,
    this.getLearningPathStatus,
    this.getNodesForPath,
    this.getNodeDetail,
    this.enrollPath,
    this.startNode,
    this.completeNode,
    this.deleteLearningPath,
  ) : super(LearningPathInitial()) {
    
    ///  FETCH ALL LEARNING PATHS
    
    on<FetchLearningPaths>(
      (event, emit) async {
        LogHandler.info('[BLoC] FetchLearningPaths event received');
        emit(LearningPathLoading());

        try {
          LogHandler.info('Fetching all learning paths...');
          final paths = await getAllLearningPaths();
          LogHandler.info('[BLoC] Successfully loaded ${paths.length} paths');
          emit(LearningPathLoaded(paths));
        } catch (e) {
          LogHandler.info('[BLoC] Error fetching paths: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    
    /// FETCH STATUS (WITH PROGRESS)
    
    on<FetchLearningPathStatus>(
      (event, emit) async {
        LogHandler.info('[BLoC] FetchLearningPathStatus event received');
        LogHandler.info('User ID: ${event.userId}');
        emit(LearningPathLoading());

        try {
          LogHandler.info('Fetching learning path status...');
          final result = await getLearningPathStatus(event.userId);
          LogHandler.info('[BLoC] Successfully loaded ${result.length} enrolled paths');
          emit(LearningPathStatusLoaded(result));
        } catch (e) {
          LogHandler.info('[BLoC] Error fetching status: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    /// FETCH OVERVIEW (ALL PATHS + ENROLLED PATHS)
    
    on<FetchLearningPathOverview>(
      (event, emit) async {
        LogHandler.info('[BLoC] FetchLearningPathOverview event received');
        LogHandler.info('User ID: ${event.userId ?? "Guest (no login)"}');
        emit(LearningPathLoading());

        try {
          LogHandler.info('Fetching all paths and enrolled paths in parallel...');
          
          if (event.userId != null) {
            // Fetch both in parallel using Future.wait
            final results = await Future.wait([
              getAllLearningPaths(),
              getLearningPathStatus(event.userId!),
            ]);
            
            final allPaths = results[0] as List<LearningPath>;
            final enrolledPaths = results[1] as List<EnrolledLearningPath>;
            
            LogHandler.info('Loaded ${allPaths.length} all paths');
            LogHandler.info('Loaded ${enrolledPaths.length} enrolled paths');

            emit(LearningPathOverviewLoaded(
              allPaths: allPaths,
              enrolledPaths: enrolledPaths,
            ));
            LogHandler.info('[BLoC] Overview loaded successfully');
          } else {
            // Guest user - only fetch all paths
            final allPaths = await getAllLearningPaths();
            LogHandler.info('Loaded ${allPaths.length} all paths (guest mode)');
            
            emit(LearningPathOverviewLoaded(
              allPaths: allPaths,
              enrolledPaths: <EnrolledLearningPath>[],
            ));
            LogHandler.info('[BLoC] Overview loaded successfully');
          }
        } catch (e) {
          LogHandler.info('[BLoC] Error fetching overview: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    /// FETCH NODES FOR PATH
    
    on<FetchNodesForPath>(
      (event, emit) async {
        LogHandler.info('[BLoC] FetchNodesForPath event received');
        LogHandler.info('Path ID: ${event.pathId}');
        LogHandler.info('User ID: ${event.userId}');
        emit(LearningPathLoading());

        try {
          LogHandler.info('Fetching nodes for path...');
          final nodes = await getNodesForPath(event.pathId, event.userId);
          LogHandler.info('[BLoC] Successfully loaded ${nodes.length} nodes');
          emit(NodesLoaded(
            pathId: event.pathId,
            nodes: nodes,
          ));
        } catch (e) {
          LogHandler.info('[BLoC] Error fetching nodes: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    /// FETCH NODE DETAIL
    
    on<FetchNodeDetail>(
      (event, emit) async {
        LogHandler.info('[BLoC] FetchNodeDetail event received');
        LogHandler.info('Node ID: ${event.nodeId}');
        LogHandler.info('User ID: ${event.userId}');
        emit(LearningPathLoading());

        try {
          LogHandler.info('Fetching node detail...');
          final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
          LogHandler.info('[BLoC] Successfully loaded node detail: ${nodeDetail.title}');
          emit(NodeDetailLoaded(nodeDetail));
        } catch (e) {
          LogHandler.info('[BLoC] Error fetching node detail: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    /// START NODE
    
    on<StartNodeEvent>(
      (event, emit) async {
        LogHandler.info('[BLoC] StartNodeEvent received');
        LogHandler.info('Node ID: ${event.nodeId}');
        LogHandler.info('User ID: ${event.userId}');
        
        try {
          LogHandler.info('Starting node...');
          await startNode(event.nodeId, event.userId);
          LogHandler.info('Node started, fetching updated detail...');
          // Optionally refetch node detail to get updated status
          final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
          LogHandler.info('[BLoC] Node started successfully');
          emit(NodeDetailLoaded(nodeDetail));
        } catch (e) {
          LogHandler.info('[BLoC] Error starting node: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: droppable(),
    );

    /// ENROLL PATH
    
    on<EnrollPathEvent>(
      (event, emit) async {
        LogHandler.info('[BLoC] EnrollPathEvent received');
        LogHandler.info('Path ID: ${event.pathId}');
        LogHandler.info('User ID: ${event.userId}');
        
        try {
          LogHandler.info('Enrolling in path...');
          await enrollPath(event.pathId, event.userId);
          LogHandler.info('[BLoC] Successfully enrolled in path');
          emit(PathEnrolled(pathId: event.pathId, userId: event.userId));
        } catch (e) {
          LogHandler.info('[BLoC] Error enrolling in path: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: droppable(),
    );

    /// COMPLETE NODE
    
    on<CompleteNodeEvent>(
      (event, emit) async {
        LogHandler.info('[BLoC] CompleteNodeEvent received');
        LogHandler.info('Node ID: ${event.nodeId}');
        LogHandler.info('User ID: ${event.userId}');
        
        try {
          LogHandler.info('Completing node...');
          await completeNode(event.nodeId, event.userId);
          LogHandler.info('Node completed, fetching updated detail...');
          // Optionally refetch node detail to get updated status
          final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
          LogHandler.info('[BLoC] Node completed successfully');
          emit(NodeDetailLoaded(nodeDetail));
        } catch (e) {
          LogHandler.info('[BLoC] Error completing node: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: droppable(),
    );

    /// DELETE LEARNING PATH
    
    on<DeleteLearningPathEvent>(
      (event, emit) async {
        LogHandler.info('[BLoC] DeleteLearningPathEvent received');
        LogHandler.info('Path ID: ${event.pathId}');
        
        try {
          LogHandler.info('Deleting learning path...');
          await deleteLearningPath(event.pathId);
          LogHandler.info('[BLoC] Learning path deleted successfully');
          
          // Refresh overview if userId is provided
          if (event.userId != null) {
            LogHandler.info('Refreshing overview in parallel...');
            
            // Fetch both in parallel using Future.wait
            final results = await Future.wait([
              getAllLearningPaths(),
              getLearningPathStatus(event.userId!),
            ]);
            
            final allPaths = results[0] as List<LearningPath>;
            final enrolledPaths = results[1] as List<EnrolledLearningPath>;
            
            LogHandler.info('Refreshed: ${allPaths.length} all paths, ${enrolledPaths.length} enrolled paths');
            
            emit(LearningPathOverviewLoaded(
              allPaths: allPaths,
              enrolledPaths: enrolledPaths,
            ));
          } else {
            emit(LearningPathDeleted('Learning path deleted successfully'));
          }
        } catch (e) {
          LogHandler.info('[BLoC] Error deleting learning path: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: droppable(),
    );
  }
}
