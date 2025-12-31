import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/mockdata/albumdata.dart';

class ReflectionTreePage extends StatelessWidget {
  const ReflectionTreePage({super.key});

  @override
  Widget build(BuildContext context) {
    final albumList = AlbumData.albums;

    return Scaffold(
      appBar: AppBarWidget(
        title: "Reflect",
        showBackButton: false,
      ),
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
  return ListView.builder(
    itemCount: albums.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(
          albums[index],
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        leading: Icon(
          Icons.photo_album,
          color: Theme.of(context).colorScheme.onPrimary, 
        ),
      );
    },
  );
}