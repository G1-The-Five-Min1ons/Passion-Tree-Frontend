import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/sections/node_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/sections/node_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/uploaded_file.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/sections/node_quiz.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/sections/node_footer.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/delete_popup.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';


class EditNodeModal extends StatefulWidget {
  final String nodeId;
  final bool isNewNode;
  
  const EditNodeModal({
    super.key,
    required this.nodeId,
    this.isNewNode = false,
  });

  @override
  State<EditNodeModal> createState() => _EditNodeModalState();
}

class _EditNodeModalState extends State<EditNodeModal> {
  String _title = '';
  String _description = '';
  String _linkInput = '';
  final List<String> _links = []; //ส่วนเพิ่มlink
  final List<UploadedFileItem> _files = []; //ส่วนเพิ่มfile

  // ===== LINK FUNCTIONS =====
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

  //  ===== FILE FUNCTIONS  =====
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result == null) return;

    setState(() {
      for (final file in result.files) {
        _files.add(
          UploadedFileItem(
            name: file.name,
            size: file.size,
            path: file.path ?? '',
          ),
        );
      }
    });
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  void _handleUpdate(BuildContext context) {
    if (_title.isEmpty || _description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description are required')),
      );
      return;
    }

    context.read<LearningPathBloc>().add(
      UpdateNodeEvent(
        nodeId: widget.nodeId,
        title: _title,
        description: _description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<LearningPathBloc, LearningPathState>(
      listener: (context, state) {
        if (state is NodeUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node updated successfully')),
          );
          Navigator.pop(context);
        } else if (state is LearningPathError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Padding(
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
                    NodeModalHeader(isNewNode: widget.isNewNode),
                    const SizedBox(height: 10),

                    // ===== INFO + MATERIALS =====
                    NodeInfoSection(
                      // ===== NODE INFO =====
                      onTitleChanged: (v) => setState(() => _title = v),
                      onDescriptionChanged: (v) => setState(() => _description = v),

                      // ===== LINKS =====
                      links: _links,
                      linkValue: _linkInput,
                      onLinkChanged: (v) => setState(() => _linkInput = v),
                      onAddLink: _addLink,
                      onRemoveLink: _removeLink,

                      // ===== FILE UPLOAD =====
                      files: _files,
                      onUploadFile: _pickFile,
                      onRemoveFile: _removeFile,
                    ),
                    
                    const SizedBox(height: 14),
                    NodeQuizSection(),

                    const SizedBox(height: 14),

                    BlocBuilder<LearningPathBloc, LearningPathState>(
                      builder: (context, state) {
                        final isLoading = state is LearningPathLoading;
                        
                        return NodeFooter(
                          onDelete: () {
                            DeletePopUp.show(
                              context,
                              title: 'Delete?',
                              body:
                                  'Are you sure you want to delete?\nThis Process cannot be undone.',
                              onDelete: () {
                                // TODO: implement delete node API
                                debugPrint('Node deleted: ${widget.nodeId}');

                                // ปิด EditNodeModal
                                Navigator.pop(context);
                              },
                            );
                          },
                          onSave: isLoading ? () {} : () => _handleUpdate(context),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
