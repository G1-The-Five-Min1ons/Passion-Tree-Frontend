import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/create_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/searchdropdown.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/tree_level_card.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';

class AddReflectPage extends StatefulWidget{
  final String userId;
  
  const AddReflectPage({
    super.key,
    required this.userId,
  });

  @override
  State<AddReflectPage> createState() => _AddReflectPageState();
}

class _AddReflectPageState extends State<AddReflectPage>{
  final SearchController _categoryController = SearchController();
  final SearchController _albumController = SearchController();
  final List<String> _subjects = 
  ['Biology 101', 
  'Genetics',
  'Microbiology',
  'Criminal Law',
  'Cybersecurity',
  'C++',
  'Cell Biology',
  'Chemistry'];

  String _selectedDifficulty = 'Easy';

  @override
  void initState() {
    super.initState();
    //Load user's albums
    context.read<AlbumBloc>().add(LoadAlbumsEvent(widget.userId));
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Reflection Tree', 
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context), 
      ), 
      body: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          final List<String> albumNames = state is AlbumsLoaded
              ? state.albums.map((album) => album.title).toList()
              : [];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin),
            child: ListView(
              padding: const EdgeInsets.only(top: AppSpacing.ymargin),
              children: [
                Text(
                  "Create\nNew Tree",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 30),
                SearchDropdown(
                  options: _subjects,
                  header: "Learning Path",
                  label: "Select Learning Path",
                  controller: _categoryController,
                  onSelected: (selectedItem) {
                    FocusScope.of(context).unfocus();
                  },
                ),

                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    "Album",
                    style: AppTypography.titleSemiBold.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: state is AlbumLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : SearchDropdown(
                              options: albumNames.isEmpty 
                                  ? ['No albums found'] 
                                  : albumNames,
                              label: "Select Album",
                              controller: _albumController,
                              onSelected: (selectedItem) {
                                FocusScope.of(context).unfocus();
                              },
                            ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      variant: AppButtonVariant.text,
                      text: 'Add',
                      onPressed: () {
                        CreatePopUp.show(context, userId: widget.userId);
                      },
                    ),
                  ],
                ),

            const SizedBox(height: 40),
            Text(
              "Dificulties",
                style: AppPixelTypography.title.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),

            Column(
              children: [
                const SizedBox(height: 24),
                  TreeLevelCard.easy(
                    isSelected: _selectedDifficulty == 'Easy',
                    onTap: () => setState(() => _selectedDifficulty = 'Easy'),
                  ),

                const SizedBox(height: 24),
                TreeLevelCard.medium(
                    isSelected: _selectedDifficulty == 'Medium',
                    onTap: () => setState(() => _selectedDifficulty = 'Medium'),
                  ),
                const SizedBox(height: 24),
                TreeLevelCard.hard(
                    isSelected: _selectedDifficulty == 'Hard',
                    onTap: () => setState(() => _selectedDifficulty = 'Hard'),
                  ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                "Create Tree",
                  style: AppPixelTypography.title.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/buttons/navigation/pixel/right_small_light.png'
                )
              ],
            ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}