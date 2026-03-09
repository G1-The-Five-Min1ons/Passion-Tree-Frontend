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
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/delete_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/create_learning_path_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/create_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/create_node_questions_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/generate_nodes_with_ai_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/get_learning_path_by_id_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/update_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/update_learning_path_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_node.dart';

class LearningPathBloc extends Bloc<LearningPathEvent, LearningPathState> {
  final GetAllLearningPaths getAllLearningPaths;
  final GetLearningPathStatus getLearningPathStatus;
  final GetNodesForPath getNodesForPath;
  final GetNodeDetail getNodeDetail;
  final EnrollPath enrollPath;
  final StartNode startNode;
  final CompleteNode completeNode;
  final DeleteLearningPath deleteLearningPath;
  final DeleteNodeUseCase deleteNodeUseCase;
  final CreateLearningPathUseCase createLearningPathUseCase;
  final CreateNodeUseCase createNodeUseCase;
  final CreateNodeQuestionsUseCase createNodeQuestionsUseCase;
  final GenerateNodesWithAIUseCase generateNodesWithAIUseCase;
  final GetLearningPathByIdUseCase getLearningPathByIdUseCase;
  final UpdateNodeUseCase updateNodeUseCase;
  final UpdateLearningPathUseCase updateLearningPathUseCase;

  LearningPathBloc(
    this.getAllLearningPaths,
    this.getLearningPathStatus,
    this.getNodesForPath,
    this.getNodeDetail,
    this.enrollPath,
    this.startNode,
    this.completeNode,
    this.deleteLearningPath,
    this.deleteNodeUseCase,
    this.createLearningPathUseCase,
    this.createNodeUseCase,
    this.createNodeQuestionsUseCase,
    this.generateNodesWithAIUseCase,
    this.getLearningPathByIdUseCase,
    this.updateLearningPathUseCase,
    this.updateNodeUseCase,
  ) : super(LearningPathInitial()) {
    
    // ===== HELPER METHODS =====
    
    /// Helper method to handle errors consistently
    void _handleError(
      Emitter<LearningPathState> emit,
      String operation,
      dynamic error,
    ) {
      LogHandler.error('[BLoC] Error in $operation: $error');
      emit(LearningPathError(error.toString()));
    }
    
    /// Helper method to execute async operations with error handling
    Future<void> _safeExecute(
      Emitter<LearningPathState> emit,
      String operation,
      Future<void> Function() action,
    ) async {
      try {
        await action();
      } catch (e) {
        _handleError(emit, operation, e);
      }
    }
    
    // ===== EVENT HANDLERS =====
    
    ///  FETCH ALL LEARNING PATHS
    
    on<FetchLearningPaths>(
      (event, emit) async {
        LogHandler.debug('[BLoC] FetchLearningPaths event received');
        emit(LearningPathLoading());

        try {
          final paths = await getAllLearningPaths();
          LogHandler.debug('[BLoC] Loaded ${paths.length} paths');
          emit(LearningPathLoaded(paths));
        } catch (e) {
          LogHandler.error('[BLoC] Error fetching paths: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    
    /// FETCH STATUS (WITH PROGRESS)
    
    on<FetchLearningPathStatus>(
      (event, emit) async {
        LogHandler.debug('[BLoC] FetchLearningPathStatus event received');
        emit(LearningPathLoading());

        try {
          final result = await getLearningPathStatus(event.userId);
          LogHandler.debug('[BLoC] Loaded ${result.length} enrolled paths');
          emit(LearningPathStatusLoaded(result));
        } catch (e) {
          LogHandler.error('[BLoC] Error fetching status: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    /// FETCH OVERVIEW (ALL PATHS + ENROLLED PATHS)
    
    on<FetchLearningPathOverview>(
      (event, emit) async {
        LogHandler.debug('[BLoC] FetchLearningPathOverview event received');
        emit(LearningPathLoading());

        try {
          if (event.userId != null) {
            // Fetch both in parallel using Future.wait
            final results = await Future.wait([
              getAllLearningPaths(),
              getLearningPathStatus(event.userId!),
            ]);
            
            final allPaths = results[0] as List<LearningPath>;
            final enrolledPaths = results[1] as List<EnrolledLearningPath>;
            
            LogHandler.debug('[BLoC] Overview: ${allPaths.length} paths, ${enrolledPaths.length} enrolled');

            emit(LearningPathOverviewLoaded(
              allPaths: allPaths,
              enrolledPaths: enrolledPaths,
            ));
          } else {
            // Guest user - only fetch all paths
            final allPaths = await getAllLearningPaths();
            LogHandler.debug('[BLoC] Overview: ${allPaths.length} paths (guest)');
            
            emit(LearningPathOverviewLoaded(
              allPaths: allPaths,
              enrolledPaths: <EnrolledLearningPath>[],
            ));
          }
        } catch (e) {
          LogHandler.error('[BLoC] Error fetching overview: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    /// FETCH NODES FOR PATH
    
    on<FetchNodesForPath>(
      (event, emit) async {
        LogHandler.debug('[BLoC] FetchNodesForPath: ${event.pathId}');
        emit(LearningPathLoading());

        try {
          final nodes = await getNodesForPath(event.pathId, event.userId);
          LogHandler.debug('[BLoC] Loaded ${nodes.length} nodes');
          emit(NodesLoaded(
            pathId: event.pathId,
            nodes: nodes,
          ));
        } catch (e) {
          LogHandler.error('[BLoC] Error fetching nodes: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    /// FETCH NODE DETAIL
    
    on<FetchNodeDetail>(
      (event, emit) async {
        LogHandler.debug('[BLoC] FetchNodeDetail: ${event.nodeId}');
        emit(LearningPathLoading());

        try {
          final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
          LogHandler.debug('[BLoC] Loaded node detail: ${nodeDetail.title}');
          emit(NodeDetailLoaded(nodeDetail));
        } catch (e) {
          LogHandler.error('[BLoC] Error fetching node detail: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    /// START NODE
    
    on<StartNodeEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] StartNodeEvent: ${event.nodeId}');
        emit(StartingNode(event.nodeId));
        
        await _safeExecute(emit, 'start node', () async {
          await startNode(event.nodeId, event.userId);
          // Refetch node detail to get updated status
          final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
          LogHandler.debug('[BLoC] Node started successfully');
          emit(NodeDetailLoaded(nodeDetail));
        });
      },
      transformer: droppable(),
    );

    /// ENROLL PATH
    
    on<EnrollPathEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] EnrollPathEvent: ${event.pathId}');
        emit(EnrollingPath(event.pathId));
        
        await _safeExecute(emit, 'enroll path', () async {
          await enrollPath(event.pathId, event.userId);
          LogHandler.info('[BLoC] Enrolled in path: ${event.pathId}');
          emit(PathEnrolled(pathId: event.pathId, userId: event.userId));
        });
      },
      transformer: droppable(),
    );

    /// COMPLETE NODE
    
    on<CompleteNodeEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] CompleteNodeEvent: ${event.nodeId}');
        emit(CompletingNode(event.nodeId));
        
        await _safeExecute(emit, 'complete node', () async {
          await completeNode(event.nodeId, event.userId);
          // Refetch node detail to get updated status
          final nodeDetail = await getNodeDetail(event.nodeId, event.userId);
          LogHandler.debug('[BLoC] Node completed successfully');
          emit(NodeDetailLoaded(nodeDetail));
        });
      },
      transformer: droppable(),
    );

    /// DELETE LEARNING PATH
    
    on<DeleteLearningPathEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] DeleteLearningPathEvent: ${event.pathId}');
        emit(DeletingLearningPath(event.pathId));
        
        await _safeExecute(emit, 'delete learning path', () async {
          await deleteLearningPath(event.pathId);
          LogHandler.info('[BLoC] Deleted path: ${event.pathId}');
          
          // Refresh overview if userId is provided
          if (event.userId != null) {
            // Fetch both in parallel using Future.wait
            final results = await Future.wait([
              getAllLearningPaths(),
              getLearningPathStatus(event.userId!),
            ]);
            
            final allPaths = results[0] as List<LearningPath>;
            final enrolledPaths = results[1] as List<EnrolledLearningPath>;
            
            emit(LearningPathOverviewLoaded(
              allPaths: allPaths,
              enrolledPaths: enrolledPaths,
            ));
          } else {
            emit(LearningPathDeleted('Learning path deleted successfully'));
          }
        });
      },
      transformer: droppable(),
    );

    on<DeleteNodeEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] DeleteNodeEvent: ${event.nodeId}');
        emit(DeletingNode(event.nodeId));

        await _safeExecute(emit, 'delete node', () async {
          await deleteNodeUseCase(event.nodeId);
          LogHandler.info('[BLoC] Deleted node: ${event.nodeId}');
          emit(NodeDeleted(event.nodeId));
        });
      },
      transformer: droppable(),
    );

    // ===== TEACHER EVENT HANDLERS =====

    on<CreateLearningPathEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] CreateLearningPathEvent received');
        emit(CreatingLearningPath());

        await _safeExecute(emit, 'create learning path', () async {
          final learningPath = CreateLearningPath(
            title: event.title,
            objective: event.objective,
            description: event.description,
            creatorId: event.creatorId,
            coverImgUrl: event.coverImgUrl,
            publishStatus: event.publishStatus,
          );
          
          LogHandler.debug('Creating learning path...');
          final pathId = await createLearningPathUseCase(learningPath);
          LogHandler.debug('[BLoC] Learning path created: $pathId');
          emit(LearningPathCreated(pathId));
        });
      },
      transformer: droppable(),
    );

    on<GenerateNodesWithAIEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] GenerateNodesWithAIEvent received');
        LogHandler.debug('Topic: ${event.topic}');
        emit(GeneratingNodesWithAI());

        await _safeExecute(emit, 'generate nodes with AI', () async {
          LogHandler.debug('Generating nodes with AI...');
          final response = await generateNodesWithAIUseCase(event.topic);
          LogHandler.debug('[BLoC] Generated ${response.nodes.length} nodes');
          emit(NodesGeneratedWithAI(
            topic: response.topic,
            nodes: response.nodes,
          ));
        });
      },
      transformer: restartable(),
    );

    on<CreateNodeEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] CreateNodeEvent received');
        emit(CreatingNode());

        await _safeExecute(emit, 'create node', () async {
          final node = CreateNode(
            title: event.title,
            description: event.description,
            pathId: event.pathId,
            sequence: event.sequence,
            linkvdo: event.linkvdo,
            materials: event.materials,
            questions: null,
          );
          
          LogHandler.debug('Creating node...');
          final nodeId = await createNodeUseCase(node);

          if (event.questions != null && event.questions!.isNotEmpty) {
            LogHandler.debug('Creating quiz questions for node...');
            await createNodeQuestionsUseCase(nodeId, event.questions!);
          }

          LogHandler.debug('[BLoC] Node created: $nodeId');
          emit(NodeCreated(nodeId));
        });
      },
      transformer: droppable(),
    );

    on<GetLearningPathByIdEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] GetLearningPathByIdEvent received');
        LogHandler.debug('Path ID: ${event.pathId}');
        emit(LearningPathLoading());

        try {
          LogHandler.debug('Fetching learning path by ID...');
          final learningPath = await getLearningPathByIdUseCase(event.pathId);
          LogHandler.debug('[BLoC] Learning path loaded: ${learningPath.id}');
          emit(LearningPathDetailLoaded(learningPath));
        } catch (e) {
          LogHandler.error('[BLoC] Error fetching learning path: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    on<UpdateNodeEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] UpdateNodeEvent received');
        LogHandler.debug('Node ID: ${event.nodeId}');
        emit(UpdatingNode(event.nodeId));

        await _safeExecute(emit, 'update node', () async {
          LogHandler.debug('Updating node...');
          await updateNodeUseCase(
            event.nodeId,
            event.title,
            event.description,
            linkvdo: event.linkvdo,
            materials: event.materials,
          );
          LogHandler.debug('[BLoC] Node updated: ${event.nodeId}');
          emit(NodeUpdated(event.nodeId));
        });
      },
      transformer: droppable(),
    );

    on<UpdateLearningPathEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] UpdateLearningPathEvent received');
        LogHandler.debug('Path ID: ${event.pathId}');
        emit(UpdatingLearningPath(event.pathId));

        await _safeExecute(emit, 'update learning path', () async {
          LogHandler.debug('Updating learning path...');
          await updateLearningPathUseCase(
            event.pathId,
            event.title,
            event.objective,
            event.description,
            event.coverImgUrl,
            event.publishStatus,
          );
          LogHandler.debug('[BLoC] Learning path updated: ${event.pathId}');
          emit(LearningPathUpdated(event.pathId));
        });
      },
      transformer: droppable(),
    );
  }
}
