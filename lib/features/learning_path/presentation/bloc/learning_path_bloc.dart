import 'package:flutter/foundation.dart';
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
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/create_learning_path_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/create_node_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/generate_nodes_with_ai_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/get_learning_path_by_id_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/update_node_usecase.dart';
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
  final CreateLearningPathUseCase createLearningPathUseCase;
  final CreateNodeUseCase createNodeUseCase;
  final GenerateNodesWithAIUseCase generateNodesWithAIUseCase;
  final GetLearningPathByIdUseCase getLearningPathByIdUseCase;
  final UpdateNodeUseCase updateNodeUseCase;

  LearningPathBloc(
    this.getAllLearningPaths,
    this.getLearningPathStatus,
    this.getNodesForPath,
    this.getNodeDetail,
    this.enrollPath,
    this.startNode,
    this.completeNode,
    this.deleteLearningPath,
    this.createLearningPathUseCase,
    this.createNodeUseCase,
    this.generateNodesWithAIUseCase,
    this.getLearningPathByIdUseCase,
    this.updateNodeUseCase,
  ) : super(LearningPathInitial()) {
    
    ///  FETCH ALL LEARNING PATHS
    
    on<FetchLearningPaths>(
      (event, emit) async {
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
      },
      transformer: restartable(),
    );

    
    /// FETCH STATUS (WITH PROGRESS)
    
    on<FetchLearningPathStatus>(
      (event, emit) async {
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
      },
      transformer: restartable(),
    );

    /// FETCH OVERVIEW (ALL PATHS + ENROLLED PATHS)
    
    on<FetchLearningPathOverview>(
      (event, emit) async {
        debugPrint('[BLoC] FetchLearningPathOverview event received');
        debugPrint('User ID: ${event.userId ?? "Guest (no login)"}');
        emit(LearningPathLoading());

        try {
          debugPrint('Fetching all paths and enrolled paths in parallel...');
          
          if (event.userId != null) {
            // Fetch both in parallel using Future.wait
            final results = await Future.wait([
              getAllLearningPaths(),
              getLearningPathStatus(event.userId!),
            ]);
            
            final allPaths = results[0] as List<LearningPath>;
            final enrolledPaths = results[1] as List<EnrolledLearningPath>;
            
            debugPrint('Loaded ${allPaths.length} all paths');
            debugPrint('Loaded ${enrolledPaths.length} enrolled paths');

            emit(LearningPathOverviewLoaded(
              allPaths: allPaths,
              enrolledPaths: enrolledPaths,
            ));
            debugPrint('[BLoC] Overview loaded successfully');
          } else {
            // Guest user - only fetch all paths
            final allPaths = await getAllLearningPaths();
            debugPrint('Loaded ${allPaths.length} all paths (guest mode)');
            
            emit(LearningPathOverviewLoaded(
              allPaths: allPaths,
              enrolledPaths: <EnrolledLearningPath>[],
            ));
            debugPrint('[BLoC] Overview loaded successfully');
          }
        } catch (e) {
          debugPrint('[BLoC] Error fetching overview: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    /// FETCH NODES FOR PATH
    
    on<FetchNodesForPath>(
      (event, emit) async {
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
      },
      transformer: restartable(),
    );

    /// FETCH NODE DETAIL
    
    on<FetchNodeDetail>(
      (event, emit) async {
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
      },
      transformer: restartable(),
    );

    /// START NODE
    
    on<StartNodeEvent>(
      (event, emit) async {
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
      },
      transformer: droppable(),
    );

    /// ENROLL PATH
    
    on<EnrollPathEvent>(
      (event, emit) async {
        debugPrint('[BLoC] EnrollPathEvent received');
        debugPrint('Path ID: ${event.pathId}');
        debugPrint('User ID: ${event.userId}');
        
        try {
          debugPrint('Enrolling in path...');
          await enrollPath(event.pathId, event.userId);
          debugPrint('[BLoC] Successfully enrolled in path');
          emit(PathEnrolled(pathId: event.pathId, userId: event.userId));
        } catch (e) {
          debugPrint('[BLoC] Error enrolling in path: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: droppable(),
    );

    /// COMPLETE NODE
    
    on<CompleteNodeEvent>(
      (event, emit) async {
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
      },
      transformer: droppable(),
    );

    /// DELETE LEARNING PATH
    
    on<DeleteLearningPathEvent>(
      (event, emit) async {
        debugPrint('[BLoC] DeleteLearningPathEvent received');
        debugPrint('Path ID: ${event.pathId}');
        
        try {
          debugPrint('Deleting learning path...');
          await deleteLearningPath(event.pathId);
          debugPrint('[BLoC] Learning path deleted successfully');
          
          // Refresh overview if userId is provided
          if (event.userId != null) {
            debugPrint('Refreshing overview in parallel...');
            
            // Fetch both in parallel using Future.wait
            final results = await Future.wait([
              getAllLearningPaths(),
              getLearningPathStatus(event.userId!),
            ]);
            
            final allPaths = results[0] as List<LearningPath>;
            final enrolledPaths = results[1] as List<EnrolledLearningPath>;
            
            debugPrint('Refreshed: ${allPaths.length} all paths, ${enrolledPaths.length} enrolled paths');
            
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
      },
      transformer: droppable(),
    );

    // ===== TEACHER EVENT HANDLERS =====

    on<CreateLearningPathEvent>(
      (event, emit) async {
        debugPrint('[BLoC] CreateLearningPathEvent received');
        emit(LearningPathLoading());

        try {
          final learningPath = CreateLearningPath(
            title: event.title,
            objective: event.objective,
            description: event.description,
            creatorId: event.creatorId,
            coverImgUrl: event.coverImgUrl,
            publishStatus: event.publishStatus,
          );
          
          debugPrint('Creating learning path...');
          final pathId = await createLearningPathUseCase(learningPath);
          debugPrint('[BLoC] Learning path created: $pathId');
          emit(LearningPathCreated(pathId));
        } catch (e) {
          debugPrint('[BLoC] Error creating learning path: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: droppable(),
    );

    on<GenerateNodesWithAIEvent>(
      (event, emit) async {
        debugPrint('[BLoC] GenerateNodesWithAIEvent received');
        debugPrint('Topic: ${event.topic}');
        emit(LearningPathLoading());

        try {
          debugPrint('Generating nodes with AI...');
          final response = await generateNodesWithAIUseCase(event.topic);
          debugPrint('[BLoC] Generated ${response.nodes.length} nodes');
          emit(NodesGeneratedWithAI(
            topic: response.topic,
            nodes: response.nodes,
          ));
        } catch (e) {
          debugPrint('[BLoC] Error generating nodes: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    on<CreateNodeEvent>(
      (event, emit) async {
        debugPrint('[BLoC] CreateNodeEvent received');
        emit(LearningPathLoading());

        try {
          final node = CreateNode(
            title: event.title,
            description: event.description,
            pathId: event.pathId,
            sequence: event.sequence,
            linkvdo: event.linkvdo,
          );
          
          debugPrint('Creating node...');
          final nodeId = await createNodeUseCase(node);
          debugPrint('[BLoC] Node created: $nodeId');
          emit(NodeCreated(nodeId));
        } catch (e) {
          debugPrint('[BLoC] Error creating node: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: droppable(),
    );

    on<GetLearningPathByIdEvent>(
      (event, emit) async {
        debugPrint('[BLoC] GetLearningPathByIdEvent received');
        debugPrint('Path ID: ${event.pathId}');
        emit(LearningPathLoading());

        try {
          debugPrint('Fetching learning path by ID...');
          final learningPath = await getLearningPathByIdUseCase(event.pathId);
          debugPrint('[BLoC] Learning path loaded: ${learningPath.id}');
          emit(LearningPathDetailLoaded(learningPath));
        } catch (e) {
          debugPrint('[BLoC] Error fetching learning path: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    on<UpdateNodeEvent>(
      (event, emit) async {
        debugPrint('[BLoC] UpdateNodeEvent received');
        debugPrint('Node ID: ${event.nodeId}');
        emit(LearningPathLoading());

        try {
          debugPrint('Updating node...');
          await updateNodeUseCase(event.nodeId, event.title, event.description);
          debugPrint('[BLoC] Node updated: ${event.nodeId}');
          emit(NodeUpdated(event.nodeId));
        } catch (e) {
          debugPrint('[BLoC] Error updating node: $e');
          emit(LearningPathError(e.toString()));
        }
      },
      transformer: droppable(),
    );
  }
}
