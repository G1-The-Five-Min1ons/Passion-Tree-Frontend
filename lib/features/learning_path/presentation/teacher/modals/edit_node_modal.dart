import 'dart:convert';
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
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_material.dart';
import 'package:passion_tree_frontend/features/upload/upload_service.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_quiz.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_question_with_choices.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_choice.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/node_questions_usecase.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditNodeModal extends StatefulWidget {
  final String nodeId;
  final bool isNewNode;
  final bool isAiPath;
  final bool isPrimaryNode;
  final int totalNodes;
  final String? pathId;
  final String? sequence;
  final NodeDetail? initialNode;
  final bool isReadOnly;
  final VoidCallback? onDeleteUnsavedNode;

  const EditNodeModal({
    super.key,
    required this.nodeId,
    this.isNewNode = false,
    this.isAiPath = false,
    this.isPrimaryNode = false,
    this.totalNodes = 0,
    this.pathId,
    this.sequence,
    this.initialNode,
    this.isReadOnly = false,
    this.onDeleteUnsavedNode,
  });

  @override
  State<EditNodeModal> createState() => _EditNodeModalState();
}

class _EditNodeModalState extends State<EditNodeModal> {
  static const String _materialNameMapKey = 'learning_path_material_name_map';

  String _title = '';
  String _description = '';
  String _videoUrl = '';
  final List<UploadedFileItem> _files = []; //ส่วนเพิ่มfile
  Map<String, String> _materialNameByUrl = {};
  List<NodeQuiz> _quizzes = []; //ส่วนเพิ่ม quiz
  bool _isUploading = false;
  bool _isSubmitting = false;

  String _normalizeVideoUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(trimmed);
    return hasScheme ? trimmed : 'https://$trimmed';
  }

  bool _isRemoteUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      return (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    }

    final normalized = _normalizeVideoUrl(trimmed);
    final normalizedUri = Uri.tryParse(normalized);
    return normalizedUri != null &&
        normalizedUri.hasAuthority &&
        normalizedUri.host.contains('.');
  }

  bool get _isValidVideoUrl {
    final value = _videoUrl.trim();
    if (value.isEmpty) return false;
    final normalized = _normalizeVideoUrl(value);
    final uri = Uri.tryParse(normalized);
    return uri != null && uri.hasAuthority && uri.host.contains('.');
  }

  String? get _videoUrlWarningText {
    final value = _videoUrl.trim();
    if (value.isEmpty) return 'Video URL is required';
    if (_isValidVideoUrl) return null;
    return 'Video URL ต้องเป็นลิงก์ที่ถูกต้อง เช่น youtube.com/...';
  }

  bool get _hasRequiredQuiz {
    return _quizzes.any(
      (quiz) =>
          quiz.question.trim().isNotEmpty &&
          quiz.choices.where((choice) => choice.trim().isNotEmpty).length >= 2,
    );
  }

  bool get _isSaveEnabled {
    return _title.trim().isNotEmpty &&
        _description.trim().isNotEmpty &&
        _isValidVideoUrl &&
        _hasRequiredQuiz;
  }

  bool get _isTitleValid => _title.trim().isNotEmpty;

  bool get _isDescriptionValid => _description.trim().isNotEmpty;

  String? get _titleWarningText {
    if (_isTitleValid) return null;
    return 'Title is required';
  }

  String? get _descriptionWarningText {
    if (_isDescriptionValid) return null;
    return 'Description is required';
  }

  String? get _quizWarningText {
    if (_hasRequiredQuiz) return null;
    return 'Please add at least 1 question with 2 or more choices.';
  }

  String _deriveDisplayFileName(String url) {
    final decoded = Uri.decodeComponent(url);
    final segments = Uri.tryParse(decoded)?.pathSegments;
    final rawName = (segments != null && segments.isNotEmpty)
        ? segments.last
        : decoded.split('/').last;

    var cleaned = rawName;
    cleaned = cleaned.replaceFirst(RegExp(r'^[0-9a-fA-F-]{8,}[_-]+'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^\d{8,}[_-]+'), '');

    if (cleaned.isEmpty) return rawName;
    return cleaned;
  }

  Future<void> _loadMaterialNameMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_materialNameMapKey);
      if (raw == null || raw.isEmpty) {
        _materialNameByUrl = {};
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _materialNameByUrl = decoded.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      }
    } catch (_) {
      _materialNameByUrl = {};
    }
  }

  Future<void> _rememberMaterialName(String url, String name) async {
    if (url.trim().isEmpty || name.trim().isEmpty) return;

    _materialNameByUrl[url] = name;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _materialNameMapKey,
        jsonEncode(_materialNameByUrl),
      );
    } catch (_) {}
  }

  Future<void> _loadExistingMaterials() async {
    final node = widget.initialNode;
    if (node == null) return;

    await _loadMaterialNameMap();
    if (!mounted) return;

    final existing = <UploadedFileItem>[];
    for (final material in node.materials) {
      if (material.url.trim().isEmpty) continue;

      final displayName =
          _materialNameByUrl[material.url] ??
          _deriveDisplayFileName(material.url);

      existing.add(
        UploadedFileItem(name: displayName, size: 0, path: material.url),
      );
    }

    setState(() {
      _files
        ..clear()
        ..addAll(existing);
    });
  }

  @override
  void initState() {
    super.initState();

    // โหลดข้อมูลเดิมถ้าเป็นการแก้ไขโหนด
    if (widget.initialNode != null) {
      _title = widget.initialNode!.title;
      _description = widget.initialNode!.description;
      _videoUrl = widget.initialNode!.linkVdo ?? '';

      _loadExistingMaterials();

      // โหลด questions และแปลงเป็น NodeQuiz
      _quizzes = widget.initialNode!.questions.map((question) {
        // หา correct choice index
        int correctIndex = 0;
        Map<int, String> reasons = {};
        final choiceIds = <String>[];

        for (int i = 0; i < question.choices.length; i++) {
          final choice = question.choices[i];
          choiceIds.add(choice.choiceId);
          if (choice.isCorrect) {
            correctIndex = i;
            if (choice.reasoning.isNotEmpty) {
              reasons[i] = choice.reasoning;
            }
          }
        }

        return NodeQuiz(
          question: question.questionText,
          choices: question.choices.map((c) => c.choiceText).toList(),
          selectedIndex: correctIndex,
          reasons: reasons,
          questionId: question.questionId,
          choiceIds: choiceIds,
        );
      }).toList();

      // Fetch latest questions only for existing backend nodes.
      if (!widget.isNewNode) {
        _loadQuestionsFromApi();
      }
    }
  }

  Future<void> _loadQuestionsFromApi() async {
    try {
      final getNodeQuestions = getIt<GetNodeQuestions>();
      final questions = await getNodeQuestions(widget.nodeId);
      if (!mounted) return;

      final quizzesFromApi = questions.map((question) {
        int correctIndex = 0;
        final reasons = <int, String>{};
        final choiceIds = <String>[];

        for (int i = 0; i < question.choices.length; i++) {
          final choice = question.choices[i];
          choiceIds.add(choice.choiceId);
          if (choice.isCorrect) {
            correctIndex = i;
            if (choice.reasoning.isNotEmpty) {
              reasons[i] = choice.reasoning;
            }
          }
        }

        return NodeQuiz(
          question: question.questionText,
          choices: question.choices.map((c) => c.choiceText).toList(),
          selectedIndex: correctIndex,
          reasons: reasons,
          questionId: question.questionId,
          choiceIds: choiceIds,
        );
      }).toList();

      setState(() {
        _quizzes = quizzesFromApi;
      });
    } catch (_) {
      // ถ้าโหลดคำถามไม่สำเร็จ จะใช้ค่าเดิมจาก initialNode แทน
    }
  }

  bool get _cannotDeleteLastNode {
    return widget.totalNodes <= 1;
  }

  bool get _isFirstNode {
    final effectiveSequence = widget.sequence != null
        ? int.tryParse(widget.sequence!)
        : widget.initialNode?.sequence;
    return effectiveSequence == 1;
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

  // Helper function to convert NodeQuiz to CreateQuestionWithChoices
  List<CreateQuestionWithChoices>? _convertQuizzesToQuestions() {
    if (_quizzes.isEmpty) return null;

    // กรองเอาแต่ questions ที่มีข้อความ
    final validQuizzes = _quizzes
        .where((q) => q.question.trim().isNotEmpty)
        .toList();
    if (validQuizzes.isEmpty) return null;

    return validQuizzes.map((quiz) {
      final choices = quiz.choices
          .asMap()
          .entries
          .where((entry) => entry.value.trim().isNotEmpty)
          .map((entry) {
            return CreateChoice(
              choiceText: entry.value,
              isCorrect: entry.key == quiz.selectedIndex,
              reasoning: quiz.reasons[entry.key] ?? '',
            );
          })
          .toList();

      return CreateQuestionWithChoices(
        questionText: quiz.question,
        type: 'multiple_choice',
        choices: choices,
      );
    }).toList();
  }

  Future<List<CreateMaterial>> _buildMaterialsForSubmit({
    required bool preserveExistingNonFileMaterials,
  }) async {
    final materials = <CreateMaterial>[];

    if (preserveExistingNonFileMaterials && widget.initialNode != null) {
      for (final material in widget.initialNode!.materials) {
        if (material.type != 'file' && material.url.trim().isNotEmpty) {
          materials.add(
            CreateMaterial(type: material.type, url: material.url.trim()),
          );
        }
      }
    }

    if (_files.isEmpty) return materials;

    final uploadService = UploadApiService();
    for (final fileItem in _files) {
      final filePath = fileItem.path;
      if (filePath == null || filePath.isEmpty) continue;

      if (_isRemoteUrl(filePath)) {
        // Keep already-uploaded materials as-is.
        materials.add(
          CreateMaterial(type: 'file', url: _normalizeVideoUrl(filePath)),
        );
        await _rememberMaterialName(
          _normalizeVideoUrl(filePath),
          fileItem.name,
        );
        continue;
      }

      final file = File(filePath);
      final publicUrl = await uploadService.uploadImage(
        file,
        'materials-nodes',
      );
      materials.add(CreateMaterial(type: 'file', url: publicUrl));
      await _rememberMaterialName(publicUrl, fileItem.name);
    }

    return materials;
  }

  Future<void> _handleUpdate(BuildContext context) async {
    // Guard against double-tap / duplicate submit while the first request is in-flight.
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    if (!_isValidVideoUrl) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Video URL ต้องเป็นลิงก์ที่ถูกต้อง เช่น youtube.com/...',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.cancel,
          ),
        );
      return;
    }

    if (widget.isNewNode) {
      // สร้าง node ใหม่
      if (widget.pathId == null || widget.sequence == null) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Missing path ID or sequence',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.cancel,
            ),
          );
        return;
      }

      setState(() => _isUploading = true);

      try {
        final materials = await _buildMaterialsForSubmit(
          preserveExistingNonFileMaterials: false,
        );

        if (!context.mounted) return;

        final questions = _convertQuizzesToQuestions();
        final normalizedVideoUrl = _normalizeVideoUrl(_videoUrl);

        context.read<LearningPathBloc>().add(
          CreateNodeEvent(
            title: _title,
            description: _description,
            pathId: widget.pathId!,
            sequence: widget.sequence!,
            linkvdo: normalizedVideoUrl,
            materials: materials,
            questions: questions,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload files: $e',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.cancel,
            ),
          );
        if (context.mounted) {
          setState(() => _isSubmitting = false);
        }
      } finally {
        if (context.mounted) {
          setState(() => _isUploading = false);
        }
      }
    } else {
      // อัปเดต node เดิม
      setState(() => _isUploading = true);

      try {
        final materials = await _buildMaterialsForSubmit(
          preserveExistingNonFileMaterials: true,
        );

        if (!context.mounted) return;

        final normalizedVideoUrl = _normalizeVideoUrl(_videoUrl);

        context.read<LearningPathBloc>().add(
          UpdateNodeEvent(
            nodeId: widget.nodeId,
            title: _title,
            description: _description,
            linkvdo: _videoUrl.isNotEmpty ? normalizedVideoUrl : null,
            materials: materials,
            quizzes: _quizzes,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload files: $e',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.cancel,
            ),
          );
        if (context.mounted) {
          setState(() => _isSubmitting = false);
        }
      } finally {
        if (context.mounted) {
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
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Node updated successfully',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                backgroundColor: AppColors.status,
              ),
            );
          if (context.mounted) {
            Navigator.pop(context);
          }
        } else if (state is NodeCreated) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Node created successfully',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                backgroundColor: AppColors.status,
              ),
            );
          if (context.mounted) {
            Navigator.pop(context);
          }
        } else if (state is NodeDeleted) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Node deleted successfully',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                backgroundColor: AppColors.status,
              ),
            );
          if (context.mounted) {
            Navigator.pop(context);
          }
        } else if (state is LearningPathError) {
          if (context.mounted) {
            setState(() => _isSubmitting = false);
          }
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                backgroundColor: AppColors.cancel,
              ),
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
                    NodeModalHeader(
                      isNewNode: widget.isNewNode,
                      isReadOnly: widget.isReadOnly,
                    ),
                    const SizedBox(height: 10),

                    // ===== INFO + MATERIALS =====
                    NodeInfoSection(
                      // ===== NODE INFO =====
                      initialTitle: _title,
                      initialDescription: _description,
                      onTitleChanged: (v) => setState(() => _title = v),
                      onDescriptionChanged: (v) =>
                          setState(() => _description = v),
                      isTitleInvalid: false,
                      isDescriptionInvalid: false,
                      titleWarningText: null,
                      descriptionWarningText: null,

                      // ===== VIDEO URL =====
                      videoUrlValue: _videoUrl,
                      onVideoUrlChanged: (v) => setState(() => _videoUrl = v),
                      videoUrlWarningText: null,
                      isVideoUrlInvalid: false,
                      isReadOnly: widget.isReadOnly,

                      // ===== FILE UPLOAD =====
                      files: _files,
                      onUploadFile: _pickFile,
                      onRemoveFile: _removeFile,
                    ),

                    const SizedBox(height: 14),
                    NodeQuizSection(
                      initialQuizzes: _quizzes.isNotEmpty ? _quizzes : null,
                      isReadOnly: widget.isReadOnly,
                      isQuizInvalid: false,
                      onQuizzesChanged: (quizzes) {
                        setState(() {
                          _quizzes = quizzes;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    if (!widget.isReadOnly)
                      BlocBuilder<LearningPathBloc, LearningPathState>(
                        builder: (context, state) {
                          final isLoading =
                              state is LearningPathLoading ||
                              _isUploading ||
                              _isSubmitting;

                          return NodeFooter(
                            onDelete: isLoading
                                ? null
                                : () {
                                    if (_isFirstNode) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'You cannot delete the first node.',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          backgroundColor: AppColors.cancel,
                                        ),
                                      );
                                      return;
                                    }

                                    DeletePopUp.show(
                                      context,
                                      title: 'Delete?',
                                      body:
                                          'Are you sure you want to delete?\nThis Process cannot be undone.',
                                      onDelete: () {
                                        if (_cannotDeleteLastNode) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Unable to delete the last node',
                                                style: TextStyle(
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              backgroundColor: AppColors.cancel,
                                            ),
                                          );
                                          return;
                                        }

                                        if (widget.isNewNode) {
                                          widget.onDeleteUnsavedNode?.call();
                                          Navigator.pop(context);
                                          return;
                                        }

                                        context.read<LearningPathBloc>().add(
                                          DeleteNodeEvent(
                                            nodeId: widget.nodeId,
                                          ),
                                        );
                                      },
                                    );
                                  },
                            onSave: isLoading || !_isSaveEnabled
                                ? null
                                : () => _handleUpdate(context),
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
