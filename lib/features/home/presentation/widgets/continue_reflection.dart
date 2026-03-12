import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/albums_reflection_tree.dart';

class ContinueReflectionSection extends StatelessWidget {
  final List<Album> albums;

  const ContinueReflectionSection({super.key, required this.albums});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (albums.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Continue Reflection',
              style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
            ),

            SizedBox(
              width: 18,
              height: 30,
              child: NavigationButton(
                direction: NavigationDirection.right,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AlbumBloc>(),
                        child: const ReflectionTreePage(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];

            return ListTile(
              title: Text(
                album.title,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onPrimary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
