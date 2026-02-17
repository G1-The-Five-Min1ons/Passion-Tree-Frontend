import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/add_reflect_page.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/tree_information_page.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/heart_status.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/recommend_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/retrieve_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/tree_status_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/tree_album.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';


class AlbumDetailPage extends StatelessWidget{
  final Album album;
  final String userId;
  final VoidCallback onBack;

  const AlbumDetailPage({
    super.key, 
    required this.album,
    required this.userId,
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
                  icon: const PixelIcon('assets/icons/Pixel_plus.png', size: 16),
                  onPressed: (){
                    final albumBloc = BlocProvider.of<AlbumBloc>(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: albumBloc,
                          child: AddReflectPage(userId: userId),
                        ),
                      ),
                    );
                  }),
                ],
              ),  
              if (album.items != null && album.items!.isNotEmpty)
              _buildItemGrid(context, album, album.items!)
            else
              _buildEmptyState(context),   

              GestureDetector(
                onTap: () {
                  RecommendPopup.show(context);
                },
                /* child: Text(
                  "recommend (mock ไว้ดู)",
                  style: AppTypography.bodyRegular.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ), */
              ),             
          ],
        ),
      ),
    );  
  }
}

  Widget _buildItemGrid(BuildContext context,Album album, List<AlbumItem> items) {
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
        
        return TreeAlbumCard(
          title: item.subjectName,
          subtitle: item.lastEdited,
          statusText: item.status, 
          statusColor: item.statusColor,
          treeStatus: item.overallStatus,
          currentAlbumname: album.title,
          resumeOn: item.resumeOn,
          dataDisplay: const SizedBox.shrink(),

          onCardTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => TreeDetailPage(item: item)),
            );
          },

          //TODO: ดึงจาก status จริง
          onStatusTap: () {
            final status = item.status.toLowerCase().trim();
            if (status == 'died') {
            RetrievePopup.show(context); 
          } else if (['growing', 'fading', 'dying'].contains(status)) {
            TreeStatusPopup.show(context, status);
          }
          },
        );
      }
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

 