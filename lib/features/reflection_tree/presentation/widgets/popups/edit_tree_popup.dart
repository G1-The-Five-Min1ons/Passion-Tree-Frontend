import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/searchdropdown.dart';

class EditTreePopUp extends StatefulWidget {
  final String title;
  final String initialName;
  final String initialPath;
  final List<String> pathOptions;

  const EditTreePopUp({
    super.key,
    required this.title,
    required this.initialName,
    required this.initialPath,
    required this.pathOptions,
  });

  @override
  State<EditTreePopUp> createState() => _EditTreePopUpState();

  static void show(
    BuildContext context, {
    String title = 'Edit\nReflection Tree',
    required String initialName,
    required String initialPath,
    required List<String> pathOptions,
  }) {
    showDialog(
      context: context,
      builder: (context) => EditTreePopUp(
        title: title,
        initialName: initialName,
        initialPath: initialPath,
        pathOptions: pathOptions,
      ),
    );
  }
}

class _EditTreePopUpState extends State<EditTreePopUp> {
  late TextEditingController _nameController;
  late SearchController _pathController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _pathController = SearchController();
    _pathController.text = widget.initialPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: 350,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(height: 16),

              PixelTextField(
                controller: _nameController,
                height: 38,
              ),

              const SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Album : ",
                    style: AppTypography.subtitleRegular.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SearchDropdown(
                      label: "Select Path",
                      options: widget.pathOptions,
                      controller: _pathController,
                      onSelected: (selected) {
                        setState(() {
                          _pathController.text = selected;
                        });
                      },
                    )
                  ),

                ],
              ),

              const SizedBox(height: 22),

              SaveCancel(
                onCancel: () => Navigator.pop(context),
                onSave: () {
                  debugPrint("New Name: ${_nameController.text}");
                  debugPrint("New Path: ${_pathController.text}");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}