import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/album_model.dart';
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
  Album? selectedAlbum;
  
  // TODO: ลบออกตอนเชื่อม authen
  final String userId = 'c2f58ec8-7611-d748-8bce-dd4768669769';

  @override
  void initState() {
    super.initState();
    context.read<AlbumBloc>().add(LoadAlbumsEvent(userId));
  }

  @override
  Widget build(BuildContext context) {
    if (selectedAlbum != null) {
      return AlbumDetailPage(
        album: selectedAlbum!,
        onBack: () {
          setState(() {
            selectedAlbum = null; 
          });
        },
      );
    }

    return Scaffold(
      appBar: const AppBarWidget(title: 'Reflection Tree', showBackButton: false),
      body: BlocConsumer<AlbumBloc, AlbumState>(
        listener: (context, state) {
          if (state is AlbumCreated) {
            context.read<AlbumBloc>().add(RefreshAlbumsEvent(userId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Album created successfully!')),
            );
          } else if (state is AlbumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                //เดี่ยวมาแก้ design
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin),
            child: ListView(
              padding: const EdgeInsets.only(top: AppSpacing.ymargin),
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
                _buildContent(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AlbumState state) {
    if (state is AlbumLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: CircularProgressIndicator(),
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

    if (state is AlbumOperationLoading && state.currentAlbums != null) {
      return _buildAlbumList(context, state.currentAlbums!);
    }

    return _buildEmptyState(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      width: double.infinity,
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
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
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
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedAlbum = album;
            });
          },
          child: PixelAlbumCover(
            size: 150,
            title: album.title,
            subtitle: album.subtitle,
            imageUrl: album.image,
          ),
        );
      },
    );
  }
}