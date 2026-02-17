import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'dart:io';

class CreatePopUp extends StatefulWidget {
  final String title;
  final String hint;
  final String userId;

  const CreatePopUp({
    super.key,
    required this.title,
    required this.hint,
    required this.userId,
  });

  @override
  State<CreatePopUp> createState() => _CreatePopUpState();

  static Future<bool?> show(
    BuildContext context, {
    required String userId,
    String title = 'Create Album',
    String hint = 'Album Name',
  }) {
    final albumBloc = BlocProvider.of<AlbumBloc>(context);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: albumBloc,
        child: CreatePopUp(
          title: title,
          hint: hint,
          userId: userId,
        ),
      ),
    );
  }
}

class _CreatePopUpState extends State<CreatePopUp> {
  final TextEditingController _albumNameController = TextEditingController();
  
  File? _selectedImage;
  String? _albumNameError;
  
  @override
  void dispose() {
    _albumNameController.dispose();
    super.dispose();
  }

  String? _validateAlbumName(String value) {
    if (value.isEmpty) {
      return 'Album name is required';
    }
    return null;
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();

    try {
      XFile? result = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (result != null) {
        setState(() {
          _selectedImage = File(result.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _createAlbum() {
    final albumName = _albumNameController.text.trim();
    final error = _validateAlbumName(albumName);
    
    setState(() {
      _albumNameError = error;
    });
    
    if (error != null) {
      return;
    }

    context.read<AlbumBloc>().add(
      CreateAlbumEvent(
        userId: widget.userId,
        albumName: albumName,
        coverImage: _selectedImage,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumBloc, AlbumState>(
      builder: (context, state) {
        final isLoading = state is ImageUploading || state is AlbumOperationLoading;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: PixelBorderContainer(
            pixelSize: 4,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 18),

                GestureDetector(
                  onTap: isLoading ? null : _pickImage,
                  child: PixelBorderContainer(
                      pixelSize: 2,
                      width: double.infinity,
                      height: 150,
                      padding: EdgeInsets.zero,
                      borderColor: AppColors.scale,
                      fillColor: AppColors.scale,
                      child: _selectedImage != null
                          ? SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: ClipRRect(
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 48,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Upload Cover Image',
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                ),

                const SizedBox(height: 18),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PixelTextField(
                      controller: _albumNameController,
                      hintText: widget.hint,
                      height: 38,
                      onChanged: (value) {
                        setState(() {
                          _albumNameError = _validateAlbumName(value.trim());
                        });
                      },
                    ),
                    if (_albumNameError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          _albumNameError!,
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.cancel,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                isLoading
                    ? const CircularProgressIndicator()
                    : SaveCancel(
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onSave: _createAlbum,
                      ),

              ],
            ),
          ),
        );
      },
    );
  }
}