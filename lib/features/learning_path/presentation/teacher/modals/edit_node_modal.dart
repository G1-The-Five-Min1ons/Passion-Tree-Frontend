import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_bottom.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/sections/node_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/sections/node_info.dart';

class EditNodeModal extends StatefulWidget {
  const EditNodeModal({super.key});

  @override
  State<EditNodeModal> createState() => _EditNodeModalState();
}

class _EditNodeModalState extends State<EditNodeModal> {
  String _title = '';
  String _description = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Center(
        child: SizedBox(
          width: 420,
          height: 650,
          child: PixelBorderContainer(
            padding: const EdgeInsets.all(16),
            borderColor: colors.primary,
            fillColor: colors.surface,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NodeModalHeader(),
                  const SizedBox(height: 10),

                  // ===== INFO + MATERIALS =====
                  NodeInfoSection(
                    onTitleChanged: (value) {
                      setState(() {
                        _title = value;
                      });
                    },
                    onDescriptionChanged: (value) {
                      setState(() {
                        _description = value;
                      });
                    },
                  ),

                 

                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
