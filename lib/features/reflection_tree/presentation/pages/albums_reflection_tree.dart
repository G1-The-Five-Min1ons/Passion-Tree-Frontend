import 'dart:async';
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

class ReflectionTreePage extends StatefulWidget {
  const ReflectionTreePage({super.key});

  @override
  State<ReflectionTreePage> createState() => _ReflectionTreePageState();
}
  
class _ReflectionTreePageState extends State<ReflectionTreePage>{
  StreamSubscription<AlbumOperationResult>? _operationSubscription;
  
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndAlbums();
    
    _operationSubscription = context.read<AlbumBloc>().albumOperationStream.listen(
      (result) {
        if (!mounted) return;
        
        switch (result.type) {
          case AlbumOperationType.created:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Album created successfully'),
                backgroundColor: AppColors.status,
              ),
            );
            break;
          case AlbumOperationType.updated:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Album updated successfully'),
                backgroundColor: AppColors.status,
              ),
            );
            break;
          case AlbumOperationType.deleted:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Album deleted successfully'),
                backgroundColor: AppColors.status,
              ),
            );
            break;
        }
      },
    );
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
    context.read<AlbumBloc>().add(LoadAlbumsEvent(userId));
  }

  @override
  void dispose() {
    _operationSubscription?.cancel();
    super.dispose();
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
        },
        builder: (context, state) {
          return CustomScrollView(
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
                          CreatePopUp.show(
                            context,
                            userId: userId,
                          );
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
              onTap: () {
                final albumBloc = BlocProvider.of<AlbumBloc>(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: albumBloc,
                      child: AlbumDetailPage(
                        album: album,
                        userId: userId,
                        onBack: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                );
              },
              child: PixelAlbumCover(
                albumId: album.albumId,
                userId: userId,
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