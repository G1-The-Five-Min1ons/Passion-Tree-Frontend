import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/add_reflect_page.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/tree_information_page.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/heart_status.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/tree_album.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc_provider.dart';


class AlbumDetailPage extends StatefulWidget {
  final String albumId;
  final VoidCallback onBack;

  const AlbumDetailPage({
    super.key, 
    required this.albumId,
    required this.onBack, 
  });

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  List<String> _availableAlbumNames = [];
  List<Album> _availableAlbums = [];
  
  @override
  void initState() {
    super.initState();
    // Load album data when page opens
    context.read<AlbumBloc>().add(LoadAlbumByIdEvent(widget.albumId));
    context.read<AlbumBloc>().add(const LoadAlbumsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return LearningPathBlocProvider(
      child: Scaffold(
        appBar: AppBarWidget(
          title: 'Reflection Tree', 
          showBackButton: true,
          onBackPressed: widget.onBack, 
        ), 
        body: BlocListener<AlbumBloc, AlbumState>(
          listener: (context, state) {
            if (state is AlbumsLoaded) {
              setState(() {
                _availableAlbumNames = state.albums.map((album) => album.title).toList();
                _availableAlbums = state.albums;
              });
              context.read<AlbumBloc>().add(LoadAlbumByIdEvent(widget.albumId));
            }
            
            if (state is AlbumDetailLoaded && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: BlocBuilder<AlbumBloc, AlbumState>(
            builder: (context, state) {
              if (state is AlbumLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AlbumOperationLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AlbumError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${state.message}',
                        style: AppTypography.bodyRegular.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        variant: AppButtonVariant.text,
                        text: 'Retry',
                        onPressed: () {
                          context.read<AlbumBloc>().add(LoadAlbumByIdEvent(widget.albumId));
                        },
                      ),
                    ],
                  ),
                );
              }

              if (state is AlbumDetailLoaded) {
                final album = state.album;
                return _buildAlbumContent(context, album);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        ),
      );
  }

  Widget _buildAlbumContent(BuildContext context, Album album) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin),
      child: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.ymargin),
        children: [
          Text(
            album.title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const HeartStatus(),
              const Spacer(),
              AppButton(
                variant: AppButtonVariant.iconOnly,
                icon: const PixelIcon('assets/icons/Pixel_plus.png', size: 16),
                onPressed: () async {
                  final albumBloc = BlocProvider.of<AlbumBloc>(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LearningPathBlocProvider(
                        child: BlocProvider.value(
                          value: albumBloc,
                          child: const AddReflectPage(),
                        ),
                      ),
                    ),
                  );
                  if (mounted) {
                    albumBloc.add(LoadAlbumByIdEvent(widget.albumId));
                  }
                },
              ),
            ],
          ),

          if (album.items != null && album.items!.isNotEmpty)
            _buildItemGrid(context, album, album.items!)
          else
            _buildEmptyState(context),   

          // GestureDetector(
          //   onTap: () {
          //     RecommendPopup.show(context);
          //   },
          //   child: Container(
          //     height: 50,
          //     child: Text('Show Recommendations'),
          //   ),
          // ),             
        ],
      ),
    );
  }

  Widget _buildItemGrid(BuildContext context,Album album, List<AlbumItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), 
      padding: const EdgeInsets.symmetric(vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1, 
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        
        return TreeAlbumCard(
          title: item.subjectName,
          subtitle: item.lastEdited,
          statusText: item.status, 
          statusColor: item.statusColor,
          treeStatus: item.overallStatus,
          currentAlbumname: album.title,
          albumOptions: _availableAlbumNames,
          availableAlbums: _availableAlbums,
          treeId: item.treeId ?? '',
          albumId: album.albumId,
          resumeOn: item.resumeOn,
          dataDisplay: const SizedBox.shrink(),

          onCardTap: () {
            final albumBloc = BlocProvider.of<AlbumBloc>(context);
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: albumBloc,
                  child: TreeDetailPage(
                    item: item,
                    albumId: album.albumId,
                  ),
                ),
              ),
            );
          },

          onDelete: () {
            if (item.treeId != null) {
              context.read<AlbumBloc>().add(
                DeleteTreeEvent(
                  treeId: item.treeId!,
                  albumId: widget.albumId,
                ),
              );
            }
          },

          //TODO: ดึงจาก status จริง
          /* onStatusTap: () {
            final status = item.status.toLowerCase().trim();
            if (status == 'died') {
            RetrievePopup.show(context); 
          } else if (['growing', 'fading', 'dying'].contains(status)) {
            TreeStatusPopup.show(context, status);
          }
          }, */
        );
      }
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: Column(
          children: [
            Text(
              "No Tree Found",
              style: AppTypography.titleRegular.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            ),
          ],
        ),
      ),
    );
  }
}