import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/mockdata/albumdata.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/album_detail_page.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album.dart';
import 'package:material_symbols_icons/symbols.dart';

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
      appBar: const AppBarWidget(title: 'Reflect', showBackButton: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin),
        child: ListView(
          padding: const EdgeInsets.only(top: AppSpacing.ymargin),
          children: [
            Text('Reflection Tree',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                ),
              const SizedBox(height: 4),

              Row(
                children: [
                  const Spacer(),
                  AppButton(
                  variant: AppButtonVariant.iconOnly,
                  icon: Icon(
                    Symbols.add_rounded,
                    weight: 700,
                    color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: (){
                    //รอใส่ logic ทีหลัง
                  }),
              ],),

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