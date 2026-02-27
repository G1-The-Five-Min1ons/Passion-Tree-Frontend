import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_state.dart';
import 'dart:io';

class EditAlbumPopup extends StatefulWidget {
  final String title;
  final String albumId;
  final String initialValue;
  final String? imageUrl;

  const EditAlbumPopup({
    super.key,
    required this.title,
    required this.albumId,
    required this.initialValue,
    this.imageUrl,
  });

  @override
  State<EditAlbumPopup> createState() => _EditAlbumPopupState();

  static Future<bool?> show(
    BuildContext context, {
    String title = 'Edit Album',
    required String albumId,
    required String initialValue,
    String? imageUrl,
  }) {
    final albumBloc = BlocProvider.of<AlbumBloc>(context);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: albumBloc,
        child: EditAlbumPopup(
          title: title,
          albumId: albumId,
          initialValue: initialValue,
          imageUrl: imageUrl,
        ),
      ),
    );
  }
}

class _EditAlbumPopupState extends State<EditAlbumPopup> {
  late TextEditingController _controller;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                          ? ClipRRect(
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  child: Image.network(
                                    widget.imageUrl!,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
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
                                              'Failed to load image',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
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
                                        'Tap to select image',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                ),

                const SizedBox(height: 18),

                PixelTextField(
                  controller: _controller,
                  height: 38,
                ),

                const SizedBox(height: 24),

                isLoading
                    ? const CircularProgressIndicator()
                    : SaveCancel(
                        onCancel: () {
                          Navigator.pop(context, false);
                        },
                        onSave: () {
                          final albumName = _controller.text.trim();
                          if (albumName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Album name is required')),
                            );
                            return;
                          }

                          context.read<AlbumBloc>().add(
                            UpdateAlbumEvent(
                              albumId: widget.albumId,
                              title: albumName,
                              coverImage: _selectedImage,
                              existingImageUrl: widget.imageUrl,
                            ),
                          );

                          Navigator.pop(context, true);
                        },
                      ),

              ],
            ),
          ),
        );
      },
    );
  }
}