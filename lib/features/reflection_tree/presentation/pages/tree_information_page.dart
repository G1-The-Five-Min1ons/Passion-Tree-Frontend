import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/node_item.dart';
import 'package:passion_tree_frontend/core/common_widgets/node/tree_canvas.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/page_header.dart';

class TreeDetailPage extends StatelessWidget {
  final AlbumItem item;

  const TreeDetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double canvasHeight = (item.chapters.length * 200.0) + 200.0;
    final double availableWidth = screenWidth - (AppSpacing.xmargin * 2);

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Reflection Tree',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin),
        child: ListView(
          padding: const EdgeInsets.only(top: AppSpacing.ymargin),
          children: [
            PageHeader(
              title: item.subjectName,
              actionIcon: Symbols.add_rounded,
              onActionPressed: () {
                // logic ทีหลัง
              },
            ),

            // ส่วนที่จัดการต้นไม้
            SizedBox(
              height: canvasHeight,
              child: TreeCanvas(
                itemCount: item.chapters.length,
                canvasWidth: availableWidth,
                nodeBuilder: (index, pos) {
                  final chapter = item.chapters[index];

                    return Positioned(
                      left: pos.dx - 40,
                      top: pos.dy - 40,
                      child: NodeItem(
                        imagePath: chapter.isEnrolled 
                            ? 'assets/images/trees/node-enrolled.png' 
                            : 'assets/images/trees/node_notenrolled.png',
                        size: 80,
                        onTap: () {
                          // logic ทีหลัง
                       },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}