import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/datasources/album_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/datasources/reflection_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/models/reflection_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/page_header.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/main_tree_image.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_node_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_reflect/add_reflect_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/detail_reflect_after/reflect_detail_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/end_reflecting.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/recommend_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/status_badge.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';

class TreeDetailPage extends StatefulWidget {
  final AlbumItem? item;
  final String? treeId;
  final String? albumId;

  const TreeDetailPage({super.key, this.item, this.treeId, this.albumId})
    : assert(
        item != null || treeId != null,
        'Either item or treeId must be provided',
      );

  @override
  State<TreeDetailPage> createState() => _TreeDetailPageState();
}

class _TreeDetailPageState extends State<TreeDetailPage> {
  static const double _recommendPopupThreshold = 0.6;

  AlbumItem? _currentItem;
  bool _hasUnlockedRecommendationBadge = false;
  final Map<String, _ReflectionViewData> _latestReflectionByNodeId = {};
  final AlbumDataSource _albumDataSource = AlbumDataSource();
  final ReflectionDataSource _reflectionDataSource = ReflectionDataSource();
  final AuthLocalDataSource _authLocalDataSource = getIt<AuthLocalDataSource>();

  bool _isDiedStatus(String? value) {
    return (value ?? '').trim().toLowerCase() == 'died';
  }

  bool _isTreeDied(AlbumItem item) {
    return _isDiedStatus(item.status) || _isDiedStatus(item.overallStatus);
  }

  bool _isTreeReflectionClosed(AlbumItem item) {
    return item.isReflectionClosed;
  }

  void _showTreeDiedSnackbar() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Retrieve the tree to continue'),
        backgroundColor: AppColors.cancel,
      ),
    );
  }

  void _showTreeIdUnavailableSnackbar() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Tree information is unavailable right now. Please try again.',
        ),
        backgroundColor: AppColors.cancel,
      ),
    );
  }

  void _updateCurrentItem(AlbumItem item) {
    if (!mounted) return;

    final hasReachedRecommendThreshold =
        _nonStandaloneReflectionProgress(item.chapters) >=
        _recommendPopupThreshold;

    setState(() {
      _currentItem = item;
      if (hasReachedRecommendThreshold) {
        _hasUnlockedRecommendationBadge = true;
      }
    });
  }

  double _nonStandaloneReflectionProgress(List<Chapter> chapters) {
    final nonStandaloneNodes = chapters
        .where((chapter) => !chapter.isStandalone)
        .toList();
    if (nonStandaloneNodes.isEmpty) {
      return 0;
    }

    final reflectedCount = nonStandaloneNodes
        .where((chapter) => chapter.hasReflection)
        .length;
    return reflectedCount / nonStandaloneNodes.length;
  }

  bool _shouldShowRecommendationBadge(AlbumItem item) {
    return _hasUnlockedRecommendationBadge ||
      _nonStandaloneReflectionProgress(item.chapters) >=
        _recommendPopupThreshold;
  }

  void _syncCurrentItemFromState(AlbumState state) {
    if (state is AlbumDetailLoaded) {
      final album = state.album;
      if (album.items != null) {
        for (final item in album.items!) {
          if (item.treeId == _currentItem?.treeId ||
              item.treeId == widget.treeId) {
            _updateCurrentItem(item);
            return;
          }
        }
      }
    } else if (state is AlbumsLoaded) {
      for (final album in state.albums) {
        if (album.items != null) {
          for (final item in album.items!) {
            if (item.treeId == _currentItem?.treeId ||
                item.treeId == widget.treeId) {
              _updateCurrentItem(item);
              return;
            }
          }
        }
      }
    }
  }

  void _handleReflectionCreated(
    Chapter chapter,
    ReflectionApiModel createdReflection,
    CreateReflectionRequest request,
  ) {
    _latestReflectionByNodeId[chapter.treeNodeId] = _ReflectionViewData(
      nodeName: chapter.name,
      level: request.feelScore,
      learn: request.learningReflect,
      feel: request.moodReflect,
      progress: request.progressScore,
      challenge: request.challengeScore,
      sentiment: createdReflection.sentimentAnalysis,
      reflectionScore: createdReflection.reflectionScore,
      summary: createdReflection.summary,
      strugglePoint: createdReflection.strugglePoint,
    );

    final currentItem = _currentItem;
    if (currentItem == null) return;
    final effectiveTreeId = currentItem.treeId ?? widget.treeId;

    final previousProgress = _nonStandaloneReflectionProgress(
      currentItem.chapters,
    );

    final reflectedChapterId = createdReflection.reflectId.trim();
    final updatedChapters = currentItem.chapters.map((itemChapter) {
      if (itemChapter.treeNodeId != chapter.treeNodeId) return itemChapter;

      return Chapter(
        treeNodeId: itemChapter.treeNodeId,
        name: itemChapter.name,
        isEnrolled: itemChapter.isEnrolled,
        status: itemChapter.status,
        complete: itemChapter.complete,
        sequence: itemChapter.sequence,
        reflectionId: reflectedChapterId.isNotEmpty
            ? reflectedChapterId
            : itemChapter.reflectionId,
        isStandalone: itemChapter.isStandalone,
      );
    }).toList();

    _updateCurrentItem(
      AlbumItem(
        treeId: currentItem.treeId,
        subjectName: currentItem.subjectName,
        lastEdited: currentItem.lastEdited,
        status: currentItem.status,
        isReflectionClosed: currentItem.isReflectionClosed,
        chapters: updatedChapters,
        overallStatus: currentItem.overallStatus,
        treeScore: currentItem.treeScore,
        isPaused: currentItem.isPaused,
        pauseFrom: currentItem.pauseFrom,
        pauseTo: currentItem.pauseTo,
        resumeOn: currentItem.resumeOn,
        pathId: currentItem.pathId,
      ),
    );

    final updatedProgress = _nonStandaloneReflectionProgress(updatedChapters);
    final crossedThreshold =
        previousProgress < _recommendPopupThreshold &&
        updatedProgress >= _recommendPopupThreshold;

    if (crossedThreshold &&
        mounted &&
        effectiveTreeId != null &&
        effectiveTreeId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        RecommendPopup.show(context, treeId: effectiveTreeId);
      });
    }
  }

  Future<void> _fetchAndShowReflectionDetail(Chapter chapter) async {
    final token = await _authLocalDataSource.getToken();
    if (token == null || token.isEmpty || !mounted) return;

    try {
      final reflection = await _reflectionDataSource.getReflectionById(
        chapter.reflectionId!,
        token,
      );
      if (!mounted) return;
      ReflectDetailPopup.show(
        context,
        nodeName: chapter.name,
        level: reflection.feelScore ?? 0,
        learn: reflection.learnText ?? '',
        feel: reflection.feelText ?? '',
        progress: reflection.progressScore ?? 0,
        challenge: reflection.challengeScore ?? 0,
        sentiment: reflection.sentimentAnalysis,
        reflectionScore: reflection.reflectionScore,
        summary: reflection.summary,
        strugglePoint: reflection.strugglePoint,
      );
    } catch (_) {
      if (!mounted) return;
      ReflectDetailPopup.show(context, nodeName: chapter.name);
    }
  }

  Future<void> _endReflectingTree() async {
    final token = await _authLocalDataSource.getToken();
    final treeId = widget.treeId ?? _currentItem?.treeId;
    if (token == null ||
        token.isEmpty ||
        treeId == null ||
        treeId.isEmpty ||
        !mounted) {
      return;
    }

    try {
      await _albumDataSource.endReflectingTree(treeId, token);
      if (!mounted) return;

      final currentItem = _currentItem;
      if (currentItem != null) {
        _updateCurrentItem(
          AlbumItem(
            treeId: currentItem.treeId,
            subjectName: currentItem.subjectName,
            lastEdited: currentItem.lastEdited,
            status: currentItem.status,
            isReflectionClosed: true,
            chapters: currentItem.chapters,
            overallStatus: currentItem.overallStatus,
            treeScore: currentItem.treeScore,
            isPaused: currentItem.isPaused,
            pauseFrom: currentItem.pauseFrom,
            pauseTo: currentItem.pauseTo,
            resumeOn: currentItem.resumeOn,
            pathId: currentItem.pathId,
          ),
        );
      }

      final albumBloc = context.read<AlbumBloc>();
      if (widget.albumId != null) {
        albumBloc.add(LoadAlbumByIdEvent(widget.albumId!));
      } else {
        albumBloc.add(const LoadAlbumsEvent());
      }
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to end reflecting: $e'),
          backgroundColor: AppColors.cancel,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _currentItem = widget.item;
    } else if (widget.treeId != null) {
      // Create a temporary AlbumItem with minimal data
      _currentItem = AlbumItem(
        treeId: widget.treeId!,
        subjectName: 'Loading...',
        overallStatus: 'growing',
        status: 'growing',
        lastEdited: 'Edited just now',
        chapters: [],
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.albumId != null) {
          context.read<AlbumBloc>().add(LoadAlbumByIdEvent(widget.albumId!));
        } else {
          context.read<AlbumBloc>().add(const LoadAlbumsEvent());
        }
      });
    }
  }

  @override
  void dispose() {
    _albumDataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlbumBloc, AlbumState>(
      listener: (context, state) {
        _syncCurrentItemFromState(state);
      },
      child: _currentItem != null
          ? _buildTreeDetail(_currentItem!)
          : Scaffold(
              appBar: AppBarWidget(
                title: 'Reflection Tree',
                showBackButton: true,
                onBackPressed: () => Navigator.pop(context),
              ),
              body: Center(
                child: widget.treeId != null
                    ? const CircularProgressIndicator()
                    : const Text('Error: No tree data available'),
              ),
            ),
    );
  }

  Widget _buildTreeDetail(AlbumItem item) {
    final int chapterCount = item.chapters.length;
    final double canvasHeight = chapterCount > 0
        ? (60.0 + ((chapterCount - 1) * 120.0) + 72.0)
        : 0;

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Reflection Tree',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ===== SCROLLABLE CONTENT (ทั้งหน้า) =====
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xmargin,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 80), // เว้นที่ให้ header ลอย

                  MainTreeImage(
                    status: item.overallStatus,
                    treeScore: item.treeScore,
                  ),

                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isTreeReflectionClosed(item))
                          StatusBadge(status: item.status),
                        if (_shouldShowRecommendationBadge(item)) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final treeId = item.treeId ?? widget.treeId;
                              if (treeId == null || treeId.isEmpty) return;
                              RecommendPopup.show(context, treeId: treeId);
                            },
                            child: const StatusBadge(
                              status: 'growing',
                              label: 'recommendations',
                              badgeColor: AppColors.title,
                              labelColor: AppColors.textPrimary,
                              width: 170,
                              horizontalPadding: 8,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (item.chapters.isNotEmpty)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double canvasWidth = constraints.maxWidth;

                        return SizedBox(
                          height: canvasHeight,
                          child: TreeCanvas(
                            itemCount: item.chapters.length,
                            canvasWidth: canvasWidth,
                            nodeBuilder: (index, pos) {
                              final chapter = item.chapters[index];

                              return Positioned(
                                left: pos.dx - 40,
                                top: pos.dy - 40,
                                child: NodeItem(
                                  imagePath: chapter.canReflect
                                      ? 'assets/images/trees/node-enrolled.png'
                                      : 'assets/images/trees/node_notenrolled.png',
                                  size: 90,
                                  onTap: () {
                                    if (_isTreeDied(item)) {
                                      _showTreeDiedSnackbar();
                                      return;
                                    }

                                    if (_isTreeReflectionClosed(item) &&
                                        !chapter.hasReflection) {
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      messenger.removeCurrentSnackBar();
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'This tree has ended. You cannot add new reflections.',
                                          ),
                                          backgroundColor: AppColors.cancel,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                      return;
                                    }

                                    if (!chapter.canReflect) {
                                      // Learning Path not completed
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      messenger.removeCurrentSnackBar();
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please finish this chapter before reflecting',
                                          ),
                                          backgroundColor: AppColors.cancel,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    } else if (chapter.hasReflection) {
                                      // Node completed and has reflection - show detail
                                      final reflectionData =
                                          _latestReflectionByNodeId[chapter
                                              .treeNodeId];

                                      if (reflectionData != null) {
                                        ReflectDetailPopup.show(
                                          context,
                                          nodeName: reflectionData.nodeName,
                                          level: reflectionData.level,
                                          learn: reflectionData.learn,
                                          feel: reflectionData.feel,
                                          progress: reflectionData.progress,
                                          challenge: reflectionData.challenge,
                                          sentiment: reflectionData.sentiment,
                                          reflectionScore:
                                              reflectionData.reflectionScore,
                                          summary: reflectionData.summary,
                                          strugglePoint:
                                              reflectionData.strugglePoint,
                                        );
                                      } else if (chapter.reflectionId != null) {
                                        _fetchAndShowReflectionDetail(chapter);
                                      } else {
                                        ReflectDetailPopup.show(
                                          context,
                                          nodeName: chapter.name,
                                        );
                                      }
                                    } else {
                                      // Node completed but no reflection yet - add new reflection
                                      AddReflectPopup.show(
                                        context,
                                        treeNodeId: chapter.treeNodeId,
                                        nodeName: chapter.name,
                                        onReflectionCreated:
                                            (createdReflection, request) {
                                              _handleReflectionCreated(
                                                chapter,
                                                createdReflection,
                                                request,
                                              );

                                              final albumBloc = context
                                                  .read<AlbumBloc>();
                                              if (widget.albumId != null) {
                                                albumBloc.add(
                                                  LoadAlbumByIdEvent(
                                                    widget.albumId!,
                                                  ),
                                                );
                                              } else {
                                                albumBloc.add(
                                                  const LoadAlbumsEvent(),
                                                );
                                              }
                                            },
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                  if (item.chapters.isNotEmpty && !_isTreeReflectionClosed(item))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: AppButton(
                        variant: AppButtonVariant.text,
                        text: 'End Reflecting',
                        onPressed: () {
                          EndReflecting.show(
                            context,
                            onConfirm: _endReflectingTree,
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            // ===== FLOATING HEADER =====
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xmargin,
                  vertical: AppSpacing.ymargin,
                ),
                child: PageHeader(
                  title: item.subjectName,
                  actionIcon: Symbols.add_rounded,
                  showAction: !_isTreeReflectionClosed(item),
                  onActionPressed: () {
                    if (_isTreeDied(item)) {
                      _showTreeDiedSnackbar();
                      return;
                    }

                    final treeId = item.treeId ?? widget.treeId;
                    if (treeId == null || treeId.isEmpty) {
                      _showTreeIdUnavailableSnackbar();
                      return;
                    }

                    final albumBloc = context.read<AlbumBloc>();

                    AddNodePopup.show(
                      context,
                      treeId: treeId,
                      onNodeAdded: (createdChapter) {
                        final currentItem = _currentItem;
                        if (currentItem != null) {
                          final updatedChapters =
                              [...currentItem.chapters, createdChapter]..sort(
                                (left, right) =>
                                    left.sequence.compareTo(right.sequence),
                              );

                          _updateCurrentItem(
                            AlbumItem(
                              treeId: currentItem.treeId,
                              subjectName: currentItem.subjectName,
                              lastEdited: currentItem.lastEdited,
                              status: currentItem.status,
                              isReflectionClosed:
                                  currentItem.isReflectionClosed,
                              chapters: updatedChapters,
                              overallStatus: currentItem.overallStatus,
                              treeScore: currentItem.treeScore,
                              isPaused: currentItem.isPaused,
                              pauseFrom: currentItem.pauseFrom,
                              pauseTo: currentItem.pauseTo,
                              resumeOn: currentItem.resumeOn,
                              pathId: currentItem.pathId,
                            ),
                          );
                        }

                        // Reload album data to show the new node
                        if (widget.albumId != null) {
                          albumBloc.add(LoadAlbumByIdEvent(widget.albumId!));
                        } else {
                          albumBloc.add(const LoadAlbumsEvent());
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReflectionViewData {
  final String nodeName;
  final int level;
  final String learn;
  final String feel;
  final int progress;
  final int challenge;
  final String sentiment;
  final double reflectionScore;
  final String summary;
  final String strugglePoint;

  const _ReflectionViewData({
    required this.nodeName,
    required this.level,
    required this.learn,
    required this.feel,
    required this.progress,
    required this.challenge,
    required this.sentiment,
    required this.reflectionScore,
    required this.summary,
    required this.strugglePoint,
  });
}
