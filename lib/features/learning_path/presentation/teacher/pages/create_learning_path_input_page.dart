import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_preview_card.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/ai_node_review_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/teacher_nodes_overview.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/upload/upload_service.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class CreateLearningPathInputPage extends StatefulWidget {
  const CreateLearningPathInputPage({super.key});

  @override
  State<CreateLearningPathInputPage> createState() =>
      _CreateLearningPathInputPageState();
}

class _CreateLearningPathInputPageState
    extends State<CreateLearningPathInputPage> {
  String _title = '';
  String _objectives = '';
  String _description = '';
  String? _createdPathId; // เก็บ pathId หลังสร้าง
  bool _isCreatingPath = false;
  String? _userId;
  
  // Image upload states
  File? _selectedImageFile;
  bool _isUploadingImage = false;
  String _uploadedImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (!mounted) return;
    setState(() => _userId = storedUserId);
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
        _isUploadingImage = true;
      });

      try {
        final uploadService = UploadApiService();
        final fileName = path.basename(image.path);

        final urls = await uploadService.getPresignedUrl(
          fileName,
          'reflect',
        );
        await uploadService.uploadFileToBlob(
          urls['upload_url']!,
          _selectedImageFile!,
        );

        setState(() {
          _uploadedImageUrl = urls['public_url']!;
          _isUploadingImage = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _selectedImageFile = null;
          _isUploadingImage = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        }
      }
    }
  }
  
  void _handleCreateWithAI(BuildContext context) {
    if (_title.isEmpty || _objectives.isEmpty || _description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    setState(() {
      _isCreatingPath = true;
    });

    context.read<LearningPathBloc>().add(
      CreateLearningPathEvent(
        title: _title,
        objective: _objectives,
        description: _description,
        creatorId: _userId!,
        coverImgUrl: _uploadedImageUrl.isNotEmpty ? _uploadedImageUrl : null,
        publishStatus: 'draft',
      ),
    );
  }

  void _handleCreatePlainPath(BuildContext context) {
    if (_title.isEmpty || _objectives.isEmpty || _description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    context.read<LearningPathBloc>().add(
      CreateLearningPathEvent(
        title: _title,
        objective: _objectives,
        description: _description,
        creatorId: _userId!,
        coverImgUrl: _uploadedImageUrl.isNotEmpty ? _uploadedImageUrl : null,
        publishStatus: 'draft',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<LearningPathBloc, LearningPathState>(
      listener: (context, state) {
        if (state is LearningPathCreated) {
          _createdPathId = state.pathId;
          
          if (_isCreatingPath) {
            // ถ้ากด AI Create Node ให้ไปหน้า AI Review
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AINodeReviewPage(
                  objective: _objectives,
                  pathId: state.pathId,
                ),
              ),
            ).then((_) {
              setState(() {
                _isCreatingPath = false;
              });
            });
          } else {
            // ถ้ากด Create Plain Path ให้ไปหน้า TeacherNodesOverviewPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherNodesOverviewPage(
                  title: _title,
                  pathId: state.pathId,
                  aiNodes: null, // ไม่มี AI nodes
                ),
              ),
            );
          }
        } else if (state is LearningPathError) {
          setState(() {
            _isCreatingPath = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: const AppBarWidget(title: 'Learning Paths', showBackButton: true),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xmargin,
                right: AppSpacing.xmargin,
                top: AppSpacing.ymargin,
                bottom: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // ===== HEADER =====
                SizedBox(
                  height: 120, // เพิ่มความสูงเพื่อรองรับ subtitle
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create a New \nLearning Path',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                

                      const SizedBox(height: 20), // ระยะห่างตามที่ต้องการ

                      Text(
                        'Fill in details to start a new path for your students',
                        style: AppTypography.subtitleSemiBold.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                
                // ===== PREVIEW CARD =====
                Center(
                  child: CoursePreviewCard(
                    title: _title,
                    instructor: 'อ.อะตอม',
                    objectives: _objectives,
                    imageUrl: _uploadedImageUrl,
                  ),
                ),


                const SizedBox(height: 20),

                // ===== PATH TITLE =====
              
                PixelTextField(
                  label: 'Path Title',
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  hintText: 'Enter learning path title',
                  height: 38,
                  onChanged: (value) {
                    setState(() {
                      _title = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ===== COVER IMAGE UPLOAD =====
                Text(
                  'Cover Image',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                
                GestureDetector(
                  onTap: _isUploadingImage ? null : _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isUploadingImage
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: colors.primary),
                                const SizedBox(height: 8),
                                Text(
                                  'Uploading...',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _selectedImageFile != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  _selectedImageFile!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: colors.error),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImageFile = null;
                                      _uploadedImageUrl = '';
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: colors.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload Cover Image',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),


                const SizedBox(height: 20),
                // ===== OBJECTIVES : TITLE =====

                PixelTextField(
                  label: 'Path Objectives',
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  hintText: 'Enter learning path objectives',
                  height: 38,
                  onChanged: (value) {
                    setState(() {
                      _objectives = value;
                    });
                  },
                ),



                const SizedBox(height: 20),

                // ===== DESCRIPTION : CONTENT =====
                PixelTextField(
                  label: 'Path Description',
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  hintText: 'Describe this learning path in detail',
                  height: 150,
                  onChanged: (value) {},
                ),

                const SizedBox(height: 30),

              // ===== Buttons =====
              //AI CREATE NODE
                BlocBuilder<LearningPathBloc, LearningPathState>(
                  builder: (context, state) {
                    final isLoading = state is LearningPathLoading;
                    
                    return Center(
                      child: Column(
                        children: [
                          AppButton(
                            variant: AppButtonVariant.text,
                            text: isLoading && _isCreatingPath ? 'Creating...' : 'AI Create Node',
                            subText: 'Use AI powered to auto generate nodes for you',
                            onPressed: isLoading ? () {} : () => _handleCreateWithAI(context),
                          ),

                          const SizedBox(height: 10),

                          //or
                          Text(
                            'or',
                            style: AppPixelTypography.smallTitle.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),

                          // Plain Path
                          const SizedBox(height: 10),
                          AppButton(
                            variant: AppButtonVariant.text,
                            text: isLoading && !_isCreatingPath ? 'Creating...' : 'Create Plain Path',
                            subText: 'Create nodes by yourself',
                            onPressed: isLoading ? () {} : () => _handleCreatePlainPath(context),
                          ),
                        ],
                      ),
                    );
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
