import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/album_model.dart';


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
        title: 'Reflect', 
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
                ],
              ),                  
          ],
        ),
      ),
    );  
  }
}