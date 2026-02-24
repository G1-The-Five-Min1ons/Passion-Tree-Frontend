import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_preview_card.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/ai_node_review_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/teacher_nodes_overview.dart';
import 'package:passion_tree_frontend/features/learning_path/data/services/learning_path_api_service.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/create_path_request.dart';
import 'package:passion_tree_frontend/features/upload/data/services/upload_service.dart';

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
  File? _selectedImageFile;
  bool _isUploadingImage = false;
  String _uploadedImageUrl = '';
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBarWidget(title: 'Learning Paths', showBackButton: true),
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
                    imageUrl:
                        _uploadedImageUrl, // ส่ง URL ที่อัพโหลดเสร็จแล้วเข้ามา
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

                // ===== UPLOAD COVER : TITLE =====
               
                Text(
                  'Upload Cover Image',
                  style: AppTypography.titleSemiBold.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),


                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () async {
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
                        debugPrint(
                          "✅ Image uploaded to Blob: $_uploadedImageUrl",
                        );
                      } catch (e) {
                        setState(() {
                          _isUploadingImage = false;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to upload image: $e'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: PixelBorderContainer(
                    width: double.infinity,
                    height: 150,
                    padding: EdgeInsets.zero,
                    child: _isUploadingImage
                        ? const Center(child: CircularProgressIndicator())
                        : _selectedImageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to upload image',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.5),
                                      ),
                                ),
                              ],
                            ),
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
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),

                const SizedBox(height: 30),

              // ===== Buttons =====
              //AI CREATE NODE
                Center(
                  child: Column(
                    children: [
                      AppButton(
                        variant: AppButtonVariant.text,
                        text: 'AI Create Node',
                        subText:
                            'Use AI powered to auto generate nodes for you',
                        onPressed: () async {
                          // 1. Validation
                          if (_title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter title'),
                              ),
                            );
                            return;
                          }

                          if (_isUploadingImage) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'กรุณารอสักครู่ กำลังอัพโหลดรูปภาพ...',
                                ),
                              ),
                            );
                            return;
                          }

                          // Show Loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (c) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            debugPrint("🚀 START PROCESS...");

                            // --- STEP A: Create Path (สร้างบ้านรอก่อน) ---
                            debugPrint("📝 Creating Path in Backend...");
                            // ต้องแก้ createLearningPath ให้ return ID กลับมาด้วยนะครับ (ใน Backend ส่งกลับมาอยู่แล้ว)
                            final request = CreatePathRequest(
                              title: _title,
                              objective: _objectives,
                              description: _description,
                              creatorId: 'feee25bd-db4e-4850-bd2c-5788ce090032', //พี่ขอ mock
                              coverImgUrl: _uploadedImageUrl,
                            );

                            // สมมติว่าแก้ service ให้ return String pathId กลับมา
                            final String pathId = await createLearningPath(request);
                            debugPrint("✅ Path Created! ID: $pathId");

                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop(); // ปิด Loading

                              // --- STEP B: Go to Review Page (พาไปดูของ) ---
                              debugPrint("➡️ Navigating to Review Page...");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AINodeReviewPage(
                                    pathId: pathId,
                                    objective: _objectives,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint("❌ ERROR: $e");
                            if (context.mounted) {
                              Navigator.pop(context); // ปิด Loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      //or
                      Text('or', style: AppPixelTypography.smallTitle.copyWith(color: Theme.of(context).colorScheme.onPrimary),),

                      // Plain Path
                      const SizedBox(height: 10),
                      AppButton(
                        variant: AppButtonVariant.text,
                        text: 'Create Plain Path',
                        subText: 'Create nodes by yourself',
                        onPressed: () async {
                          // 1. Validation
                          if (_title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter title'),
                              ),
                            );
                            return;
                          }
                          
                          if (_isUploadingImage) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'กรุณารอสักครู่ กำลังอัพโหลดรูปภาพ...',
                                ),
                              ),
                            );
                            return;
                          }

                          // Show Loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (c) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            debugPrint("🚀 START PLAIN PATH CREATION...");

                            // --- STEP A: Create Path ---
                            debugPrint("📝 Creating Path in Backend...");
                            final request = CreatePathRequest(
                              title: _title,
                              objective: _objectives,
                              description: _description,
                              creatorId: 'feee25bd-db4e-4850-bd2c-5788ce090032',
                              coverImgUrl: _uploadedImageUrl,
                            );

                            final String pathId = await createLearningPath(request);
                            debugPrint("✅ Path Created! ID: $pathId");

                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();

                              // --- STEP B: Go to Nodes Overview Page ---
                              debugPrint("➡️ Navigating to Nodes Overview Page...");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TeacherNodesOverviewPage(
                                    title: 'Nodes Overview',
                                    pathId: pathId,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint("❌ ERROR: $e");
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
