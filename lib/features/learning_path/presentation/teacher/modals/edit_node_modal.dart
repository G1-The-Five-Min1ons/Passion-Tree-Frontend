import 'dart:io';
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
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';
import 'package:passion_tree_frontend/features/upload/upload_service.dart';


class EditNodeModal extends StatefulWidget {
  final String nodeId;
  final bool isNewNode;
  final String? pathId;
  final String? sequence;
  
  const EditNodeModal({
    super.key,
    required this.nodeId,
    this.isNewNode = false,
    this.pathId,
    this.sequence,
  });

  @override
  State<EditNodeModal> createState() => _EditNodeModalState();
}

class _EditNodeModalState extends State<EditNodeModal> {
  String _title = '';
  String _description = '';
  String _videoUrl = '';
  String _linkInput = '';
  final List<String> _links = []; //ส่วนเพิ่มlink
  final List<UploadedFileItem> _files = []; //ส่วนเพิ่มfile
  bool _isUploading = false;

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

  Future<void> _handleUpdate(BuildContext context) async {
    if (_title.isEmpty || _description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description are required')),
      );
      return;
    }

    if (widget.isNewNode) {
      // สร้าง node ใหม่
      if (widget.pathId == null || widget.sequence == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing path ID or sequence')),
        );
        return;
      }

      setState(() => _isUploading = true);

      try {
        // Upload files และรวม materials
        List<CreateMaterial> materials = [];
        
        // เพิ่ม links
        for (final link in _links) {
          materials.add(CreateMaterial(type: 'link', url: link));
        }
        
        // Upload files และเพิ่ม URLs
        if (_files.isNotEmpty) {
          final uploadService = UploadApiService();
          
          for (final fileItem in _files) {
            final path = fileItem.path;
            if (path != null && path.isNotEmpty) {
              final file = File(path);
              final publicUrl = await uploadService.uploadImage(
                file,
                'learning-materials',
              );
              materials.add(CreateMaterial(type: 'file', url: publicUrl));
            }
          }
        }

        if (!mounted) return;
        
        context.read<LearningPathBloc>().add(
          CreateNodeEvent(
            title: _title,
            description: _description,
            pathId: widget.pathId!,
            sequence: widget.sequence!,
            linkvdo: _videoUrl,
            materials: materials.isNotEmpty ? materials : null,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload files: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    } else {
      // อัปเดต node เดิม
      setState(() => _isUploading = true);

      try {
        // Upload files และรวม materials
        List<CreateMaterial> materials = [];
        
        // เพิ่ม links
        for (final link in _links) {
          materials.add(CreateMaterial(type: 'link', url: link));
        }
        
        // Upload files และเพิ่ม URLs
        if (_files.isNotEmpty) {
          final uploadService = UploadApiService();
          
          for (final fileItem in _files) {
            final path = fileItem.path;
            if (path != null && path.isNotEmpty) {
              final file = File(path);
              final publicUrl = await uploadService.uploadImage(
                file,
                'learning-materials',
              );
              materials.add(CreateMaterial(type: 'file', url: publicUrl));
            }
          }
        }

        if (!mounted) return;

        context.read<LearningPathBloc>().add(
          UpdateNodeEvent(
            nodeId: widget.nodeId,
            title: _title,
            description: _description,
            linkvdo: _videoUrl.isNotEmpty ? _videoUrl : null,
            materials: materials.isNotEmpty ? materials : null,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload files: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
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
        } else if (state is NodeCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node created successfully')),
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

                      // ===== VIDEO URL =====
                      videoUrlValue: _videoUrl,
                      onVideoUrlChanged: (v) => setState(() => _videoUrl = v),

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
                        final isLoading = state is LearningPathLoading || _isUploading;
                        
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
