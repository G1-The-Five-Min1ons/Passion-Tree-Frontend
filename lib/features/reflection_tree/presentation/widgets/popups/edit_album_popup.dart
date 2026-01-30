import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';

class EditAlbumPopup extends StatefulWidget {
  final String title;
  final String initialValue;

  const EditAlbumPopup({
    super.key,
    required this.title,
    required this.initialValue,
  });

  @override
  State<EditAlbumPopup> createState() => _EditAlbumPopupState();

  static void show(
    BuildContext context, {
    String title = 'Edit Album',
    required String initialValue,
  }) {
    showDialog(
      context: context,
      builder: (context) => EditAlbumPopup(
        title: title,
        initialValue: initialValue,
      ),
    );
  }
}

class _EditAlbumPopupState extends State<EditAlbumPopup> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              onTap: () {
                // รอใส่ logic
              },
              child: PixelBorderContainer(
                  pixelSize: 2,
                  width: double.infinity,
                  height: 150,
                  padding: EdgeInsets.zero,
                  borderColor: AppColors.scale,
                  fillColor: AppColors.scale,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
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

            SaveCancel(
              onCancel: () {
                Navigator.pop(context);
              },
              onSave: () {
                Navigator.pop(context);
              },
            ),

          ],
        ),
      ),
    );
  }
}