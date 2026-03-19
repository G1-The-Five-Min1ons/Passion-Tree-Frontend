import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/album_detail_page.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/page_header.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/create_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc_provider.dart';

class ReflectionTreePage extends StatefulWidget {
  const ReflectionTreePage({super.key});

  @override
  State<ReflectionTreePage> createState() => _ReflectionTreePageState();
}
  
class _ReflectionTreePageState extends State<ReflectionTreePage>{
  
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndAlbums();
  }

  Future<void> _loadUserAndAlbums() async {
    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (storedUserId == null || storedUserId.isEmpty) {
      LogHandler.error('No user ID found — cannot load albums');
      return;
    }
    if (!mounted) return;
    setState(() => userId = storedUserId);
    LogHandler.info('Loading albums for user: $userId');
    context.read<AlbumBloc>().add(const LoadAlbumsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Reflection Tree', showBackButton: false),
      body: BlocConsumer<AlbumBloc, AlbumState>(
        listener: (context, state) {
          if (state is AlbumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          
          // Show success message when albums are loaded with a message
          if (state is AlbumsLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.status,
              ),
            );
          }
        },
        builder: (context, state) {        
          final key = state is AlbumsLoaded 
              ? ValueKey('albums_${state.albums.length}_${state.albums.map((a) => a.albumId).join('_')}')
              : const ValueKey('no_albums');
          
          return CustomScrollView(
            key: key,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin)
                    .copyWith(top: AppSpacing.ymargin),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      PageHeader(
                        title: "Albums",
                        actionIcon: Symbols.add_rounded,
                        onActionPressed: () {
                          CreatePopUp.show(context);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildContent(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AlbumState state) {
    if (state is AlbumLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (state is AlbumsLoaded) {
      if (state.albums.isEmpty) {
        return _buildEmptyState(context);
      }
      return _buildAlbumList(context, state.albums);
    }

    if (state is AlbumError) {
      return _buildErrorState(context, state.message);
    }

    if (state is ImageUploading) {
      if (state.currentAlbums != null && state.currentAlbums!.isNotEmpty) {
        return _buildAlbumList(context, state.currentAlbums!);
      }
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (state is AlbumOperationLoading) {
      if (state.currentAlbums != null && state.currentAlbums!.isNotEmpty) {
        return _buildAlbumList(context, state.currentAlbums!);
      } else {
        return SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }
    }

    return _buildEmptyState(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Text(
            'No Album Found',
            textAlign: TextAlign.center,
            style: AppTypography.titleRegular.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Symbols.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: AppTypography.titleSemiBold.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyRegular.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumList(BuildContext context, List<Album> albums) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin)
          .copyWith(bottom: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final album = albums[index];

            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlbumBlocProvider(
                      child: AlbumDetailPage(
                        albumId: album.albumId,
                        onBack: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                );
                // Reload albums when returning from detail page
                if (context.mounted) {
                  context.read<AlbumBloc>().add(const RefreshAlbumsEvent());
                }
              },
              child: PixelAlbumCover(
                albumId: album.albumId,
                size: 150,
                title: album.title,
                subtitle: album.subtitle,
                imageUrl: album.image,
              ),
            );
          },
          childCount: albums.length,
        ),
      ),
    );
  }
}