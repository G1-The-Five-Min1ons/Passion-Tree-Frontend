import 'dart:io';
import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/sections/node_header.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/sections/node_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/uploaded_file.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/sections/node_quiz.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/modals/sections/node_footer.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/delete_popup.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_node_request.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_quiz.dart';
import 'package:passion_tree_frontend/features/upload/data/services/upload_service.dart';

class EditNodeModal extends StatefulWidget {
  final String? initialTitle;
  final bool isEditMode;
  final Function(
    String title,
    String desc,
    String linkVdo,
    List<CreateMaterialRequest> materials,
    List<CreateQuestionWithChoicesRequest> questions,
  )?
  onSaveData;

  const EditNodeModal({
    super.key,
    this.initialTitle,
    this.onSaveData,
    this.isEditMode = true,
  });

  @override
  State<EditNodeModal> createState() => _EditNodeModalState();
}

class _EditNodeModalState extends State<EditNodeModal> {
  // ===== STATE =====
  late TextEditingController _titleController;
  String _description = '';
  String _linkInput = '';
  final List<String> _links = [];
  final List<UploadedFileItem> _files = [];
  List<NodeQuiz> _currentQuizzes = [];

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // [เพิ่ม] กำหนดค่าเริ่มต้นให้ Controller
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
  }

  @override
  void dispose() {
    // [เพิ่ม] อย่าลืม dispose
    _titleController.dispose();
    super.dispose();
  }

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

  final UploadApiService _uploadService = UploadApiService();

  Future<String> _uploadFileToBlob(UploadedFileItem fileItem) async {
    if (fileItem.path == null || fileItem.path!.isEmpty) {
      throw Exception('File path is null or empty. Cannot upload.');
    }

    final file = File(fileItem.path!);

    final urls = await _uploadService.getPresignedUrl(
      fileItem.name,
      'materials-nodes', 
    );

    final uploadUrl = urls['upload_url'];
    final publicUrl = urls['public_url'];

    if (uploadUrl == null || publicUrl == null) {
      throw Exception('Invalid URLs received from backend.');
    }

    await _uploadService.uploadFileToBlob(uploadUrl, file);

    return publicUrl;
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
          child: Stack(
            children: [
              PixelBorderContainer(
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
                        titleController: _titleController,
                        onDescriptionChanged: (v) => _description = v,

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
                      NodeQuizSection(
                        onChanged: (updatedQuizzes) {
                          _currentQuizzes = updatedQuizzes;
                        },
                      ),

                      const SizedBox(height: 14),

                      NodeFooter(
                        onDelete: () {
                          DeletePopUp.show(
                            context,
                            title: 'Delete?',
                            body:
                                'Are you sure you want to delete?\nThis Process cannot be undone.',
                            onDelete: () {
                              debugPrint('Node deleted');
                              Navigator.pop(context);
                            },
                          );
                        },
                        onSave: () async {
                          setState(() => _isUploading = true);

                          try {
                            String linkVdo = _links.isNotEmpty
                                ? _links.first
                                : '';

                            List<CreateMaterialRequest> apiMaterials = [];
                            for (var file in _files) {
                              final uploadedUrl = await _uploadFileToBlob(file);
                              apiMaterials.add(
                                CreateMaterialRequest(
                                  type: 'file',
                                  url: uploadedUrl,
                                ),
                              );
                            }

                            List<CreateQuestionWithChoicesRequest>
                            apiQuestions = _currentQuizzes.map((q) {
                              List<CreateChoiceRequest> apiChoices = [];
                              for (int i = 0; i < q.choices.length; i++) {
                                apiChoices.add(
                                  CreateChoiceRequest(
                                    choiceText: q.choices[i],
                                    isCorrect: i == q.selectedIndex,
                                    reasoning: q.reasons[i] ?? '',
                                  ),
                                );
                              }

                              return CreateQuestionWithChoicesRequest(
                                questionText: q.question,
                                type: 'multiple_choice',
                                choices: apiChoices,
                              );
                            }).toList();

                            apiQuestions = apiQuestions
                                .where((q) => q.questionText.isNotEmpty)
                                .toList();

                            if (widget.onSaveData != null) {
                              widget.onSaveData!(
                                _titleController.text,
                                _description,
                                linkVdo,
                                apiMaterials,
                                apiQuestions,
                              );
                            }

                            if (mounted) Navigator.pop(context);
                          } catch (e) {
                            debugPrint("Upload Error: $e");
                          } finally {
                            if (mounted)
                              setState(
                                () => _isUploading = false,
                              );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              if (_isUploading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
