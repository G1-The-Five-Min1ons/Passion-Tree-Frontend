import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/mockdata/albumdata.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/album_detail_page.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/page_header.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/create_popup.dart';

class ReflectionTreePage extends StatefulWidget {
  const ReflectionTreePage({super.key});

  @override
  State<ReflectionTreePage> createState() => _ReflectionTreePageState();
}
  
class _ReflectionTreePageState extends State<ReflectionTreePage>{
  Album? selectedAlbum;


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

    final albumList = AlbumData.albums;

    return Scaffold(
      appBar: const AppBarWidget(title: 'Reflection Tree', showBackButton: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin),
        child: ListView(
          padding: const EdgeInsets.only(top: AppSpacing.ymargin),
          children: [
              PageHeader(
              title: "Albums",
              actionIcon: Symbols.add_rounded,
              onActionPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context){
                    return const CreatePopUp(
                      title: "Create Album",
                      hint: "Album Name",
                    );
                  });
              },
            ),

                albumList.isEmpty 
                ? _buildEmptyState(context)
                : _buildAlbumList(context, albumList),
              
          ],
        ),
      ),
    );
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

Widget _buildAlbumList(BuildContext context, List<Album> albums) {
  return GridView.builder(
    padding: const EdgeInsets.symmetric(vertical: 20),
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
              },
            );
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