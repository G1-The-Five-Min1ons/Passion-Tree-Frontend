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

  const TreeDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
                children: [
                  const SizedBox(height: 120), // 👈 เว้นที่ให้ header ลอย

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
                      );
                    },
                  ),

                  const SizedBox(
                    height: 120,
                  ), // 👈 เว้นล่าง (เผื่อปุ่ม/gesture)
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
                    // logic ทีหลัง
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

