import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/create_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/searchdropdown.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/tree_level_card.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/pages/tree_information_page.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class AddReflectPage extends StatefulWidget{
  final String? initialAlbumId;
  final String? initialAlbumName;
  
  const AddReflectPage({
    super.key,
    this.initialAlbumId,
    this.initialAlbumName,
  });

  @override
  State<AddReflectPage> createState() => _AddReflectPageState();
}

class _AddReflectPageState extends State<AddReflectPage>{
  final SearchController _categoryController = SearchController();
  final SearchController _albumController = SearchController();

  String _selectedDifficulty = 'Easy';
  String? _selectedPathId;
  String? _selectedAlbumId;
  List<String> _availableAlbumNames = [];
  List<dynamic> _availableAlbums = [];

  @override
  void initState() {
    super.initState();
    _selectedAlbumId = widget.initialAlbumId;
    if ((widget.initialAlbumName ?? '').isNotEmpty) {
      _albumController.text = widget.initialAlbumName!;
    }

    //Load user's albums
    context.read<AlbumBloc>().add(const LoadAlbumsEvent());
    //Load enrolled learning paths
    _loadLearningPaths();
  }

  Future<void> _loadLearningPaths() async {
    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (!mounted) return;

    if (storedUserId != null && storedUserId.isNotEmpty) {
      context.read<LearningPathBloc>().add(
        FetchLearningPathStatus(userId: storedUserId),
      );
    }
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
      body: BlocListener<AlbumBloc, AlbumState>(
        listener: (context, state) {
          if (state is AlbumsLoaded) {
            setState(() {
              _availableAlbumNames = state.albums.map((album) => album.title).toList();
              _availableAlbums = state.albums;

              if ((_selectedAlbumId ?? '').isNotEmpty) {
                try {
                  final selectedAlbum = state.albums.firstWhere(
                    (album) => album.albumId == _selectedAlbumId,
                  );
                  _albumController.text = selectedAlbum.title;
                } catch (_) {
                }
              }
            });
          }
          
          if (state is TreeCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
            final albumBloc = context.read<AlbumBloc>();
            final albumId = _selectedAlbumId!;
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: albumBloc,
                    child: TreeDetailPage(
                      treeId: state.treeId,
                      albumId: albumId,
                    ),
                  ),
                ),
              );
            });
          } else if (state is AlbumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, albumState) {
          final bool isLoadingAlbums = albumState is AlbumLoading;

          return BlocBuilder<LearningPathBloc, LearningPathState>(
            builder: (context, learningPathState) {
              final bool isLoadingPaths = learningPathState is LearningPathLoading;
              
              final learningPaths = learningPathState is LearningPathStatusLoaded 
                  ? learningPathState.paths 
                  : [];
              final availableLearningPaths = learningPaths.where((path) {
                return path.completedNodes == 0 && path.progressPercent <= 0;
              }).toList();
              final List<String> availableLearningPathTitles =
                  availableLearningPaths
                    .map<String>((path) => path.title as String)
                      .toList(growable: false);

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
                    isLoadingPaths
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : SearchDropdown(
                          options: availableLearningPathTitles.isEmpty
                                ? ['No Learning Paths Available']
                            : availableLearningPathTitles,
                            header: "Learning Path",
                            label: "Select Learning Path",
                            controller: _categoryController,
                            onSelected: (selectedItem) {
                              // Find the selected path ID
                              if (availableLearningPaths.isEmpty) return;
                              
                              try {
                                final selectedPath = availableLearningPaths.firstWhere(
                                  (path) => path.title == selectedItem,
                                );
                                setState(() {
                                  _selectedPathId = selectedPath.pathId;
                                });
                              } catch (e) {
                                // If not found, just ignore
                              }
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
                          child: isLoadingAlbums
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : SearchDropdown(
                                  options: _availableAlbumNames.isEmpty 
                                      ? ['No albums found'] 
                                      : _availableAlbumNames,
                                  label: "Select Album",
                                  controller: _albumController,
                                  onSelected: (selectedItem) {
                                    // Find the selected album ID
                                    if (_availableAlbums.isEmpty) return;
                                    
                                    try {
                                      final selectedAlbum = _availableAlbums.firstWhere(
                                        (album) => album.title == selectedItem,
                                      );
                                      setState(() {
                                        _selectedAlbumId = selectedAlbum.albumId;
                                        _albumController.text = selectedAlbum.title;
                                      });
                                    } catch (e) {
                                      // If not found, just ignore
                                    }
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          variant: AppButtonVariant.text,
                          text: 'Add',
                          onPressed: () {
                            CreatePopUp.show(context);
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
                    GestureDetector(
                      onTap: () {
                        if (_selectedPathId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a learning path'),
                              backgroundColor: AppColors.cancel,
                            ),
                          );
                          return;
                        }
                        if (_selectedAlbumId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select an album'),
                              backgroundColor: AppColors.cancel,
                            ),
                          );
                          return;
                        }
                        
                        // Create tree
                        final treeTitle = _categoryController.text.isEmpty 
                            ? 'My Tree' 
                            : _categoryController.text;
                        
                        context.read<AlbumBloc>().add(
                          CreateTreeEvent(
                            title: treeTitle,
                            difficulties: _selectedDifficulty,
                            pathId: _selectedPathId!,
                            albumId: _selectedAlbumId!,
                          ),
                        );
                      },
                      child: Row(
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
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}