import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/learning_node_content.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_quiz.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/student_learning/node_comments_section.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/homebar_visibility.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LearningNodePage extends StatefulWidget {
  final String nodeId;
  final String pathId;
  final String? pathName;
  final int? totalNodes;
  final int? currentNodeSequence;
  final String userId;

  const LearningNodePage({
    super.key,
    required this.nodeId,
    required this.pathId,
    this.pathName,
    this.totalNodes,
    this.currentNodeSequence,
    required this.userId,
  });

  @override
  State<LearningNodePage> createState() => _LearningNodePageState();
}

class _LearningNodePageState extends State<LearningNodePage> {
  NodeDetail? _cachedNodeDetail;
  YoutubePlayerController? _videoController;
  bool _isFullscreen = false;
  Duration? _savedPosition;

  @override
  void initState() {
    super.initState();
    LogHandler.info('Action: User joined learning node ${widget.nodeId}');
    context.read<LearningPathBloc>().add(
      StartNodeEvent(nodeId: widget.nodeId),
    );
    context.read<LearningPathBloc>().add(
      FetchNodeDetail(nodeId: widget.nodeId),
    );
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoControllerUpdate);
    homeBarVisibilityNotifier.value = true;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _videoController?.dispose();
    super.dispose();
  }

  void _onVideoControllerUpdate() {
    final controller = _videoController;
    if (controller == null) return;

    final isFullscreen = controller.value.isFullScreen;
    if (isFullscreen == _isFullscreen) return;

    _isFullscreen = isFullscreen;
    if (isFullscreen) {
      _savedPosition = controller.value.position;
      homeBarVisibilityNotifier.value = false;
      // Hide all system overlays while video is in fullscreen.
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: const [],
      );
      // Seek to saved position in case the player restarts on fullscreen entry.
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _savedPosition != null) {
          controller.seekTo(_savedPosition!);
        }
      });
    } else {
      // Save current position (watched in fullscreen) before the rebuild resets it.
      _savedPosition = controller.value.position;
      homeBarVisibilityNotifier.value = true;
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _savedPosition != null) {
          controller.seekTo(_savedPosition!);
          _savedPosition = null;
        }
      });
    }
  }

  void _initVideoController(String? videoUrl) {
    if (_videoController != null) return;
    final url = videoUrl ?? 'https://youtu.be/Yf4M3WZilRI?si=HU_zfUG1GzGMizNb';
    final videoId = YoutubePlayer.convertUrlToId(url) ?? '';
    if (videoId.isNotEmpty) {
      final controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
      controller.addListener(_onVideoControllerUpdate);

      setState(() {
        _videoController = controller;
      });
    }
  }

  Widget _buildScaffold(BuildContext context, {Widget? player}) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: true),
      body: SafeArea(
        child: BlocBuilder<LearningPathBloc, LearningPathState>(
          builder: (context, state) {
            if (state is NodeDetailLoaded) {
              _cachedNodeDetail = state.nodeDetail;
            }

            if ((state is LearningPathLoading ||
                    state is LearningPathInitial) &&
                _cachedNodeDetail == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LearningPathError && _cachedNodeDetail == null) {
              return Center(child: Text('Error: ${state.message}'));
            }

            final nodeDetail = _cachedNodeDetail;

            if (nodeDetail != null) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xmargin,
                    right: AppSpacing.xmargin,
                    top: AppSpacing.ymargin,
                    bottom: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ===== NODE CONTENT =====
                      LearningNodeContent(
                        title: nodeDetail.title,
                        description: nodeDetail.description,
                        materials: nodeDetail.materials,
                        status: nodeDetail.status,
                        videoUrl: nodeDetail.linkVdo,
                        controller: _videoController,
                        player: player,
                        onTakeQuiz: () async {
                          final bloc = context.read<LearningPathBloc>();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: bloc,
                                child: LearningPathQuizPage(
                                  nodeId: widget.nodeId,
                                  pathId: widget.pathId,
                                  title: nodeDetail.title,
                                  pathName: widget.pathName,
                                  totalNodes: widget.totalNodes,
                                  currentNodeSequence:
                                      widget.currentNodeSequence,
                                  userId: widget.userId,
                                ),
                              ),
                            ),
                          );
                          if (mounted) {
                            bloc.add(
                              FetchNodeDetail(
                                nodeId: widget.nodeId,
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 32),

                      /// ===== COMMENTS =====
                      CommentsSection(
                        nodeId: widget.nodeId,
                        userId: widget.userId,
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LearningPathBloc, LearningPathState>(
      listener: (context, state) {
        if (state is NodeDetailLoaded) {
          _initVideoController(state.nodeDetail.linkVdo);
        }
      },
      child: _videoController != null
          ? YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _videoController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Theme.of(context).colorScheme.primary,
              ),
              builder: (context, player) =>
                  _buildScaffold(context, player: player),
            )
          : _buildScaffold(context),
    );
  }
}
