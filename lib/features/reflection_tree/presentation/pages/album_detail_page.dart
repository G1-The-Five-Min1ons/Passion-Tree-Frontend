import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/add_reflect_page.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/tree_information_page.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/heart_status.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/tree_album.dart';


class AlbumDetailPage extends StatelessWidget{
  final Album album;
  final VoidCallback onBack;

  const AlbumDetailPage({
    super.key, 
    required this.album, 
    required this.onBack, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBarWidget(
        title: 'Reflection Tree', 
        showBackButton: true,
        onBackPressed: onBack, 
      ), 
      body: Padding(
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
                  icon: Icon(
                    Symbols.add_rounded,
                    weight: 700,
                    color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddReflectPage(),
                        ),
                      );
                  }),
                ],
              ),  
              if (album.items != null && album.items!.isNotEmpty)
              _buildItemGrid(context, album.items!)
            else
              _buildEmptyState(context),                
          ],
        ),
      ),
    );  
  }
}

  Widget _buildItemGrid(BuildContext context, List<AlbumItem> items) {
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
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TreeDetailPage(item: item),
          ),);
        },
        
        child: TreeAlbumCard(
          title: item.subjectName,
          subtitle: item.lastEdited,
          statusText: item.status, 
          statusColor: item.statusColor,
          treeStatus: item.overallStatus,
          dataDisplay: const SizedBox.shrink(),
          ),
        );
      },
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

 