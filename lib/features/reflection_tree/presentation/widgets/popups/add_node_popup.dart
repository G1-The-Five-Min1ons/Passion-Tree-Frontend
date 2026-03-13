import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/datasources/album_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';

class AddNodePopup extends StatefulWidget {
  final String treeId;
  final ValueChanged<Chapter>? onNodeAdded;

  const AddNodePopup({
    super.key,
    required this.treeId,
    this.onNodeAdded,
  });

  static void show(
    BuildContext context, {
    required String treeId,
    ValueChanged<Chapter>? onNodeAdded,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddNodePopup(
        treeId: treeId,
        onNodeAdded: onNodeAdded,
      ),
    );
  }

  @override
  State<AddNodePopup> createState() => _AddNodePopupState();
}

class _AddNodePopupState extends State<AddNodePopup> {
  final _albumDataSource = AlbumDataSource();
  final _authLocalDataSource = AuthLocalDataSourceImpl();
  final _nodeNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSave() async {
    if (_nodeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter node name'),
          backgroundColor: AppColors.cancel,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _authLocalDataSource.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      LogHandler.separator(title: 'ADD NODE TO TREE');
      LogHandler.info('Tree ID: ${widget.treeId}');
      LogHandler.info('Node Name: ${_nodeNameController.text.trim()}');

      LogHandler.info('Creating standalone reflection node...');
      final treeNodeRequest = CreateTreeNodeRequest(
        nodeTitle: _nodeNameController.text.trim(),
        treeId: widget.treeId,
      );

      final treeNode = await _albumDataSource.createTreeNode(treeNodeRequest, token);
      LogHandler.success('Standalone tree node created successfully!');

      final createdChapter = Chapter(
        treeNodeId: treeNode.treeNodeId,
        name: treeNode.nodeTitle,
        isEnrolled: false,
        status: treeNode.status,
        complete: treeNode.complete,
        sequence: treeNode.sequence,
        reflectionId: treeNode.reflectionId,
        isStandalone: true,
      );

      if (!mounted) return;

      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Node added successfully!'),
          backgroundColor: AppColors.status,
        ),
      );

      widget.onNodeAdded?.call(createdChapter);
    } catch (e, stackTrace) {
      LogHandler.error('Failed to add node: $e');
      LogHandler.error('Stack trace: $stackTrace');
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add node: $e'),
          backgroundColor: AppColors.cancel,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          PixelBorderContainer(
            pixelSize: 4,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Add Node",
                  style: AppPixelTypography.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                PixelTextField(
                  label: 'Node name : ',
                  hintText: 'Enter Node name',
                  height: 38,
                  controller: _nodeNameController,
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const CircularProgressIndicator()
                    : SaveCancel(
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onSave: _handleSave,
                      ),
              ], 
            ),
          ),
          Positioned(
            top: 4,
            right: 6,
            child: IconTheme(
              data: const IconThemeData(size: 24),
              child: CloseIcon(
                color: AppColors.textSecondary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nodeNameController.dispose();
    _albumDataSource.dispose();
    super.dispose();
  }
}