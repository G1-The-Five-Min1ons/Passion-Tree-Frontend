import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/page_header.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/main_tree_image.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_node_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_reflect/add_reflect_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/detail_reflect_after/reflect_detail_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/status_badge.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';

class TreeDetailPage extends StatefulWidget {
  final AlbumItem? item;
  final String? treeId;
  final String? albumId;

  const TreeDetailPage({
    super.key, 
    this.item, 
    this.treeId,
    this.albumId,
  }) : assert(item != null || treeId != null, 'Either item or treeId must be provided');


  @override
  State<TreeDetailPage> createState() => _TreeDetailPageState();
}

class _TreeDetailPageState extends State<TreeDetailPage> {
  AlbumItem? _currentItem;

  void _updateCurrentItem(AlbumItem item) {
    if (!mounted) return;
    setState(() {
      _currentItem = item;
    });
  }

  void _syncCurrentItemFromState(AlbumState state) {
    if (state is AlbumDetailLoaded) {
      final album = state.album;
      if (album.items != null) {
        for (final item in album.items!) {
          if (item.treeId == _currentItem?.treeId || item.treeId == widget.treeId) {
            _updateCurrentItem(item);
            return;
          }
        }
      }
    } else if (state is AlbumsLoaded) {
      for (final album in state.albums) {
        if (album.items != null) {
          for (final item in album.items!) {
            if (item.treeId == _currentItem?.treeId || item.treeId == widget.treeId) {
              _updateCurrentItem(item);
              return;
            }
          }
        }
      }
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
        overallStatus: 'active',
        status: 'active',
        lastEdited:'Edited just now',
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
    final double canvasHeight = (item.chapters.length * 200.0) + 200.0;

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

                  MainTreeImage(status: item.overallStatus),

                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: StatusBadge(status: item.status),
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
                                    if (!chapter.canReflect) {
                                      // Learning Path not completed
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Please finish this chapter before reflecting'),
                                          backgroundColor: AppColors.cancel,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    } else if (chapter.hasReflection) {
                                      // Node completed and has reflection - show detail
                                      ReflectDetailPopup.show(context);
                                    } else {
                                      // Node completed but no reflection yet - add new reflection
                                      AddReflectPopup.show(
                                        context,
                                        treeNodeId: chapter.treeNodeId,    
                                        nodeName: chapter.name,
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
                  onActionPressed: () {
                    final albumBloc = context.read<AlbumBloc>();
                    
                    AddNodePopup.show(
                      context,
                      treeId: item.treeId!,
                      onNodeAdded: (createdChapter) {
                        final currentItem = _currentItem;
                        if (currentItem != null) {
                          final updatedChapters = [...currentItem.chapters, createdChapter]
                            ..sort((left, right) => left.sequence.compareTo(right.sequence));

                          _updateCurrentItem(
                            AlbumItem(
                              treeId: currentItem.treeId,
                              subjectName: currentItem.subjectName,
                              lastEdited: currentItem.lastEdited,
                              status: currentItem.status,
                              chapters: updatedChapters,
                              overallStatus: currentItem.overallStatus,
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

