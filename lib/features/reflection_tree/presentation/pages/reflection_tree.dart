import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/mockdata/albumdata.dart';

import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album.dart';

class ReflectionTreePage extends StatelessWidget {
  const ReflectionTreePage({super.key});

  @override
  Widget build(BuildContext context) {
    final albumList = AlbumData.albums;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xmargin,
          top: AppSpacing.ymargin,
          right: AppSpacing.xmargin
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reflection Tree',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                ),
                Expanded(child: albumList.isEmpty 
                ? _buildEmptyState(context)
                : _buildAlbumList(context, albumList),
                ),
          ],
        ),
      ),
    );
  }
}

Widget _buildEmptyState(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
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

//mock แบบดึงข้อมูลมาแสดง แต่ยังไม่ใช่ design จริง
Widget _buildAlbumList(BuildContext context, List<String> albums) {
  return GridView.builder(
    padding: const EdgeInsets.symmetric(vertical: 20),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
    ),
    itemCount: albums.length,
    itemBuilder: (context, index) {
      return PixelAlbumCover(
        size: 150,
        title: albums[index],
        subtitle: 'Edited 10 minutes ago',
        imageUrl: 'https://res.cloudinary.com/jerrick/image/upload/v1509742245/q0l5lwzd91liplir3odz.jpg',
      );
    },
  );
}