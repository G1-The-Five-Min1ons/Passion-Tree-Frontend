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
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_quiz.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_question_with_choices.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/create_choice.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/quiz_question.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/usecases/node_questions_usecase.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';


class EditNodeModal extends StatefulWidget {
  final String nodeId;
  final bool isNewNode;
  final String? pathId;
  final String? sequence;
  final NodeDetail? initialNode;
  
  const EditNodeModal({
    super.key,
    required this.nodeId,
    this.isNewNode = false,
    this.pathId,
    this.sequence,
    this.initialNode,
  });

  @override
  State<EditNodeModal> createState() => _EditNodeModalState();
}

class _EditNodeModalState extends State<EditNodeModal> {
  String _title = '';
  String _description = '';
  String _videoUrl = '';
  final List<UploadedFileItem> _files = []; //ส่วนเพิ่มfile
  List<NodeQuiz> _quizzes = []; //ส่วนเพิ่ม quiz
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    
    // โหลดข้อมูลเดิมถ้าเป็นการแก้ไขโหนด
    if (widget.initialNode != null) {
      _title = widget.initialNode!.title;
      _description = widget.initialNode!.description;
      _videoUrl = widget.initialNode!.linkVdo ?? '';
      
      // โหลด materials (files ที่มีอยู่แล้ว)
      for (final material in widget.initialNode!.materials) {
        if (material.type == 'file') {
          // สำหรับไฟล์ที่มีอยู่แล้ว แสดงเป็น URL (ไม่สามารถ edit ได้แต่แสดงให้เห็น)
          _files.add(
            UploadedFileItem(
              name: material.url.split('/').last,
              size: 0, // ไม่ทราบขนาดไฟล์
              path: material.url, // เก็บ URL แทน path
            ),
          );
        }
      }

      // โหลด questions และแปลงเป็น NodeQuiz
      _quizzes = widget.initialNode!.questions.map((question) {
        // หา correct choice index
        int correctIndex = 0;
        Map<int, String> reasons = {};
        
        for (int i = 0; i < question.choices.length; i++) {
          final choice = question.choices[i];
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
        );
      }).toList();

      // ดึงคำถามล่าสุดจาก API เฉพาะหน้าแก้ไขโหนด
      _loadQuestionsFromApi();
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

        for (int i = 0; i < question.choices.length; i++) {
          final choice = question.choices[i];
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
        );
      }).toList();

      setState(() {
        _quizzes = quizzesFromApi;
      });
    } catch (_) {
      // ถ้าโหลดคำถามไม่สำเร็จ จะใช้ค่าเดิมจาก initialNode แทน
    }
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
    final validQuizzes = _quizzes.where((q) => q.question.trim().isNotEmpty).toList();
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
      }).toList();

      return CreateQuestionWithChoices(
        questionText: quiz.question,
        type: 'multiple_choice',
        choices: choices,
      );
    }).toList();
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

        // Upload files และเพิ่ม URLs
        if (_files.isNotEmpty) {
          final uploadService = UploadApiService();

          for (final fileItem in _files) {
            final path = fileItem.path;
            if (path != null && path.isNotEmpty) {
              final file = File(path);
              final publicUrl = await uploadService.uploadImage(
                file,
                'materials-nodes',
              );
              materials.add(CreateMaterial(type: 'file', url: publicUrl));
            }
          }
        }

        if (!mounted) return;

        final questions = _convertQuizzesToQuestions();

        context.read<LearningPathBloc>().add(
          CreateNodeEvent(
            title: _title,
            description: _description,
            pathId: widget.pathId!,
            sequence: widget.sequence!,
            linkvdo: _videoUrl,
            materials: materials.isNotEmpty ? materials : null,
            questions: questions,
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

        // Upload files และเพิ่ม URLs
        if (_files.isNotEmpty) {
          final uploadService = UploadApiService();

          for (final fileItem in _files) {
            final path = fileItem.path;
            if (path != null && path.isNotEmpty) {
              final file = File(path);
              final publicUrl = await uploadService.uploadImage(
                file,
                'materials-nodes',
              );
              materials.add(CreateMaterial(type: 'file', url: publicUrl));
            }
          }
        }

        if (!mounted) return;

        final questions = _convertQuizzesToQuestions();

        context.read<LearningPathBloc>().add(
          UpdateNodeEvent(
            nodeId: widget.nodeId,
            title: _title,
            description: _description,
            linkvdo: _videoUrl.isNotEmpty ? _videoUrl : null,
            materials: materials.isNotEmpty ? materials : null,
            questions: questions,
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
          // Delay closing modal to allow parent listeners to process and refetch
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else if (state is NodeCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node created successfully')),
          );
          // Delay closing modal to allow parent listeners to process and refetch
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else if (state is NodeDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node deleted successfully')),
          );
          if (mounted) {
            Navigator.pop(context);
          }
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
                      initialTitle: _title.isEmpty ? null : _title,
                      initialDescription: _description.isEmpty ? null : _description,
                      onTitleChanged: (v) => setState(() => _title = v),
                      onDescriptionChanged: (v) => setState(() => _description = v),

                      // ===== VIDEO URL =====
                      videoUrlValue: _videoUrl.isEmpty ? null : _videoUrl,
                      onVideoUrlChanged: (v) => setState(() => _videoUrl = v),

                      // ===== FILE UPLOAD =====
                      files: _files,
                      onUploadFile: _pickFile,
                      onRemoveFile: _removeFile,
                    ),
                    
                    const SizedBox(height: 14),
                    NodeQuizSection(
                      initialQuizzes: _quizzes.isNotEmpty ? _quizzes : null,
                      onQuizzesChanged: (quizzes) {
                        setState(() {
                          _quizzes = quizzes;
                        });
                      },
                    ),

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
                                if (widget.isNewNode) {
                                  Navigator.pop(context);
                                  return;
                                }

                                context.read<LearningPathBloc>().add(
                                  DeleteNodeEvent(nodeId: widget.nodeId),
                                );
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
