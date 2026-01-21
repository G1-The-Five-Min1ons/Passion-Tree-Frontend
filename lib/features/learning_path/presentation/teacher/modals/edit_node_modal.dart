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
  String _linkInput = '';
  final List<String> _links = [];

  void _addLink() {
    if (_linkInput.trim().isEmpty) return;

    setState(() {
      _links.add(_linkInput.trim());
      _linkInput = '';
    });
  }

  void _removeLink(int index) {
    setState(() {
      _links.removeAt(index);
    });
  }

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
                    links: _links,
                    onTitleChanged: (v) => _title = v,
                    onDescriptionChanged: (v) => _description = v,
                    onLinkChanged: (v) => setState(() => _linkInput = v),
                    onAddLink: _addLink,
                    onRemoveLink: _removeLink,
                    linkValue: _linkInput,
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
