import 'package:passion_tree_frontend/core/network/log_handler.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
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
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/reorder_nodes_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/create_choice_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/delete_choice_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_node.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_question_with_choices.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_choice.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/update_question_usecase.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/update_choice_usecase.dart';

class LearningPathBloc extends Bloc<LearningPathEvent, LearningPathState> {
  final GetAllLearningPaths getAllLearningPaths;
  final GetRecommendedLearningPaths getRecommendedLearningPaths;
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
  final ReorderNodesUseCase reorderNodesUseCase;
  final UpdateQuestionUseCase updateQuestionUseCase;
  final UpdateChoiceUseCase updateChoiceUseCase;
  final CreateChoiceUseCase createChoiceUseCase;
  final DeleteChoiceUseCase deleteChoiceUseCase;

  LearningPathBloc(
    this.getAllLearningPaths,
    this.getRecommendedLearningPaths,
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
    this.reorderNodesUseCase,
    this.updateQuestionUseCase,
    this.updateChoiceUseCase,
    this.createChoiceUseCase,
    this.deleteChoiceUseCase,
  ) : super(LearningPathInitial()) {
    
    /// Helper method to handle errors consistently
    void handleError(
      Emitter<LearningPathState> emit,
      String operation,
      dynamic error,
    ) {
      LogHandler.error('[BLoC] Error in $operation: $error');
      emit(LearningPathError(error.toString()));
    }
    
    /// Helper method to execute async operations with error handling
    Future<void> safeExecute(
      Emitter<LearningPathState> emit,
      String operation,
      Future<void> Function() action,
    ) async {
      try {
        await action();
      } catch (e) {
        handleError(emit, operation, e);
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
          final userId = await getIt<IAuthRepository>().getUserId();
          final result = await getLearningPathStatus(userId ?? '');
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
          final userId = await getIt<IAuthRepository>().getUserId();
          // Always fetch recommendedPaths (API will use auth header)
          final List<dynamic> results = await Future.wait([
            getAllLearningPaths(),
            getLearningPathStatus(userId ?? ''),
            getRecommendedLearningPaths(),
          ]);
          final List<LearningPath> allPaths = List<LearningPath>.from(results[0] as List);
          final List<EnrolledLearningPath> enrolledPaths = List<EnrolledLearningPath>.from(results[1] as List);
          final List<LearningPath> recommendedPaths = List<LearningPath>.from(results[2] as List);
          LogHandler.debug('[BLoC] Overview: \\${allPaths.length} all, \\${enrolledPaths.length} enrolled, \\${recommendedPaths.length} recommended');
          emit(LearningPathOverviewLoaded(
            allPaths: allPaths,
            enrolledPaths: enrolledPaths,
            recommendedPaths: recommendedPaths,
          ));
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
          final userId = await getIt<IAuthRepository>().getUserId();
          final nodes = await getNodesForPath(event.pathId, userId ?? '');
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
          final userId = await getIt<IAuthRepository>().getUserId();
          final nodeDetail = await getNodeDetail(event.nodeId, userId ?? '');
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
        
        await safeExecute(emit, 'start node', () async {
          final userId = await getIt<IAuthRepository>().getUserId();
          await startNode(event.nodeId, userId ?? '');
          // Refetch node detail to get updated status
          final nodeDetail = await getNodeDetail(event.nodeId, userId ?? '');
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
        
        await safeExecute(emit, 'enroll path', () async {
          final userId = await getIt<IAuthRepository>().getUserId();
          // Step 1: Enroll in the path
          await enrollPath(event.pathId, userId ?? '');
          LogHandler.info('[BLoC] Enrolled in path: ${event.pathId}');
          
          // Step 2: Fetch updated enrolled paths to get the enrolled data
          final enrolledPaths = await getLearningPathStatus(userId ?? '');
          
          // Step 3: Find the newly enrolled path
          final enrolledPath = enrolledPaths.firstWhere(
            (path) => path.pathId == event.pathId,
            orElse: () => throw Exception('Enrolled path not found after enrollment'),
          );
          
          LogHandler.debug('[BLoC] Fetched enrolled path data: ${enrolledPath.title}');
          emit(PathEnrolled(
            pathId: event.pathId,
            userId: userId ?? '',
            enrolledPath: enrolledPath,
          ));
        });
      },
      transformer: droppable(),
    );

    /// COMPLETE NODE
    
    on<CompleteNodeEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] CompleteNodeEvent: ${event.nodeId}');
        emit(CompletingNode(event.nodeId));
        
        await safeExecute(emit, 'complete node', () async {
          final userId = await getIt<IAuthRepository>().getUserId();
          await completeNode(event.nodeId, userId ?? '');
          // Refetch node detail to get updated status
          final nodeDetail = await getNodeDetail(event.nodeId, userId ?? '');
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
        
        await safeExecute(emit, 'delete learning path', () async {
          await deleteLearningPath(event.pathId);
          LogHandler.info('[BLoC] Deleted path: ${event.pathId}');

          // Always emit deleted with appropriate message first
          final deleteMessage = event.publishStatus?.toLowerCase() == 'draft'
              ? 'Learning path draft deleted successfully'
              : 'Learning path deleted successfully';
          emit(LearningPathDeleted(deleteMessage));

          // Refresh overview
          final userId = await getIt<IAuthRepository>().getUserId();
          if (userId != null && userId.isNotEmpty) {
            final results = await Future.wait([
              getAllLearningPaths(),
              getLearningPathStatus(userId),
              getRecommendedLearningPaths(),
            ]);

            final allPaths = results[0] as List<LearningPath>;
            final enrolledPaths = results[1] as List<EnrolledLearningPath>;
            final recommendedPaths = (results[2] as List<LearningPath>)
                .where((p) => p.id != event.pathId)
                .toList();

            emit(LearningPathOverviewLoaded(
              allPaths: allPaths,
              enrolledPaths: enrolledPaths,
              recommendedPaths: recommendedPaths,
            ));
          }
        });
      },
      transformer: droppable(),
    );

    on<DeleteNodeEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] DeleteNodeEvent: ${event.nodeId}');
        emit(DeletingNode(event.nodeId));

        await safeExecute(emit, 'delete node', () async {
          await deleteNodeUseCase(event.nodeId);
          LogHandler.info('[BLoC] Deleted node: ${event.nodeId}');
          emit(NodeDeleted(event.nodeId));
        });
      },
      transformer: droppable(),
    );

    on<ReorderNodesEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] ReorderNodesEvent: ${event.pathId}');

        await safeExecute(emit, 'reorder nodes', () async {
          await reorderNodesUseCase(event.pathId, event.nodeIds);
          LogHandler.info('[BLoC] Nodes reordered: ${event.pathId}');
          emit(NodesReordered(event.pathId));
        });
      },
      transformer: droppable(),
    );

    // ===== TEACHER EVENT HANDLERS =====

    on<CreateLearningPathEvent>(
      (event, emit) async {
        LogHandler.debug('[BLoC] CreateLearningPathEvent received');
        emit(CreatingLearningPath());

        await safeExecute(emit, 'create learning path', () async {
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

        await safeExecute(emit, 'generate nodes with AI', () async {
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

        await safeExecute(emit, 'create node', () async {
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

        await safeExecute(emit, 'update node', () async {
          LogHandler.debug('Updating node...');
          await updateNodeUseCase(
            event.nodeId,
            event.title,
            event.description,
            linkvdo: event.linkvdo,
            materials: event.materials,
          );

          // Keep backward compatibility: update existing quiz IDs and create newly added quizzes.
          final quizzes = event.quizzes ?? const [];
          if (quizzes.isNotEmpty) {
            LogHandler.debug('Updating ${quizzes.length} quizzes...');
            final List<CreateQuestionWithChoices> newQuestions = [];

            for (final quiz in quizzes) {
              if (quiz.questionId == null || quiz.questionId!.isEmpty) {
                final newChoices = quiz.choices
                    .asMap()
                    .entries
                    .where((entry) => entry.value.trim().isNotEmpty)
                    .map(
                      (entry) => CreateChoice(
                        choiceText: entry.value,
                        isCorrect: entry.key == quiz.selectedIndex,
                        reasoning: quiz.reasons[entry.key] ?? '',
                      ),
                    )
                    .toList();

                if (quiz.question.trim().isNotEmpty && newChoices.isNotEmpty) {
                  newQuestions.add(
                    CreateQuestionWithChoices(
                      questionText: quiz.question,
                      type: 'multiple_choice',
                      choices: newChoices,
                    ),
                  );
                }
                continue;
              }

              await updateQuestionUseCase(
                quiz.questionId!,
                quiz.question,
                'multiple_choice',
              );

              final choiceIds = quiz.choiceIds == null
                  ? <String>[]
                  : List<String>.from(quiz.choiceIds!);
              final currentChoices = quiz.choices;

              final sharedCount = choiceIds.length < currentChoices.length
                  ? choiceIds.length
                  : currentChoices.length;

              for (var i = 0; i < sharedCount; i++) {
                final choiceId = choiceIds[i];
                if (choiceId.isEmpty) {
                  await createChoiceUseCase(
                    quiz.questionId!,
                    currentChoices[i],
                    i == quiz.selectedIndex,
                    quiz.reasons[i] ?? '',
                  );
                  continue;
                }

                await updateChoiceUseCase(
                  choiceId,
                  currentChoices[i],
                  i == quiz.selectedIndex,
                  quiz.reasons[i] ?? '',
                );
              }

              if (currentChoices.length > choiceIds.length) {
                for (var i = choiceIds.length; i < currentChoices.length; i++) {
                  if (currentChoices[i].trim().isEmpty) continue;
                  await createChoiceUseCase(
                    quiz.questionId!,
                    currentChoices[i],
                    i == quiz.selectedIndex,
                    quiz.reasons[i] ?? '',
                  );
                }
              }

              if (choiceIds.length > currentChoices.length) {
                for (var i = currentChoices.length; i < choiceIds.length; i++) {
                  final choiceId = choiceIds[i];
                  if (choiceId.isEmpty) continue;
                  await deleteChoiceUseCase(choiceId);
                }
              }
            }

            if (newQuestions.isNotEmpty) {
              await createNodeQuestionsUseCase(event.nodeId, newQuestions);
            }
          }

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

        await safeExecute(emit, 'update learning path', () async {
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
