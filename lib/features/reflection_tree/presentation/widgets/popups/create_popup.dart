import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/repositories/album_repository.dart';
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
    }
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CreatePopUp(
        title: title,
        hint: hint,
        userId: userId,
      ),
    );
  }
}



class _CreatePopUpState extends State<CreatePopUp> {
  final TextEditingController _albumNameController = TextEditingController();
  final AlbumRepository _repository = AlbumRepository();
  
  File? _selectedImage;
  String? _selectedImagePath;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _albumNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();

    try {
      XFile? result = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (result != null) {
        setState(() {
          _selectedImagePath = result.path;
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

  Future<void> _createAlbum() async {
    if (_albumNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter album name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Upload image to storage and get URL
      final coverImageUrl = _selectedImagePath ?? '';
      
      await _repository.createAlbum(
        userId: widget.userId,
        albumName: _albumNameController.text.trim(),
        coverImageUrl: coverImageUrl,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Album created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create album : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: _isLoading ? null : _pickImage,
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

            PixelTextField(
              controller: _albumNameController,
              hintText: widget.hint,
              height: 38,
            ),

            const SizedBox(height: 24),

            _isLoading
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
  }
}