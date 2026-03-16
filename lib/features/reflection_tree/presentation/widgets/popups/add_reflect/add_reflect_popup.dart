import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/datasources/reflection_data_source.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/models/reflection_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_reflect/page._two.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_reflect/page_one.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_reflect/page_three.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_reflect/reflection_overview.dart';

class AddReflectPopup extends StatefulWidget {
  final String treeNodeId;
  final String nodeName;
  final void Function(
    ReflectionApiModel createdReflection,
    CreateReflectionRequest request,
  )?
  onReflectionCreated;

  const AddReflectPopup({
    super.key,
    required this.treeNodeId,
    required this.nodeName,
    this.onReflectionCreated,
  });

  static void show(
    BuildContext context, {
    required String treeNodeId,
    required String nodeName,
    void Function(ReflectionApiModel, CreateReflectionRequest)?
    onReflectionCreated,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddReflectPopup(
        treeNodeId: treeNodeId,
        nodeName: nodeName,
        onReflectionCreated: onReflectionCreated,
      ),
    );
  }

  @override
  State<AddReflectPopup> createState() => _AddReflectPopupState();
}

class _AddReflectPopupState extends State<AddReflectPopup> {
  final PageController _pageController = PageController();
  final ReflectionDataSource _reflectionDataSource = ReflectionDataSource();
  final AuthLocalDataSource _authLocalDataSource = getIt<AuthLocalDataSource>();

  int _currentPage = 0;
  bool _isSubmitting = false;

  String learn = "";
  String feel = "";
  int score = 0;
  int progress = 0;
  int challenge = 0;

  bool get _canGoNext {
    if (_currentPage == 0) return learn.trim().isNotEmpty;
    if (_currentPage == 1) return score > 0 && feel.trim().isNotEmpty;
    if (_currentPage == 2) return progress > 0 && challenge > 0;
    return true;
  }

  Future<void> _submitReflection() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await _authLocalDataSource.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final request = CreateReflectionRequest(
        learningReflect: learn,
        moodReflect: feel,
        feelScore: score,
        progressScore: progress,
        challengeScore: challenge,
        treeNodeId: widget.treeNodeId,
      );

      // Call API
      final createdReflection = await _reflectionDataSource.createReflection(
        request,
        token,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onReflectionCreated?.call(createdReflection, request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reflected successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 380,
            height: 600,
            child: PixelBorderContainer(
              pixelSize: 4,
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  if (_currentPage < 3) ...[
                    const SizedBox(height: 10),
                    Text("Add Reflect", style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: 20),
                  ] else ...[
                    const SizedBox(height: 10),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Node: ${widget.nodeName}',
                      style: AppTypography.h3SemiBold,
                    ),
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      children: [
                        PageOneView(
                          initialValue: learn,
                          onLearnChanged: (val) => setState(() => learn = val),
                        ),
                        PageTwoView(
                          initialScore: score,
                          initialText: feel,
                          onScoreChanged: (val) => setState(() => score = val),
                          onTextChanged: (val) => setState(() => feel = val),
                        ),
                        PageThreeView(
                          initialProgress: progress,
                          initialChallenge: challenge,
                          onProgressChanged: (val) => setState(() => progress = val),
                          onChallengeChanged: (val) => setState(() => challenge = val),
                        ),
                        ReflectionOverview(
                          learn: learn,
                          feel: feel,
                          level: score,
                          progress: progress,
                          challenge: challenge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildStepBar(),
                ],
              ),
            ),
          ),

          Positioned(
            right: 8,
            top: 8,
            child: IconTheme(
              data: const IconThemeData(size: 24),
              child: CloseIcon(
                color: AppColors.textSecondary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          if (_isSubmitting)
            Positioned.fill(
              child: Container(
                color: AppColors.scale.withValues(alpha: 0.2),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepBar() {
    if (_currentPage == 3) {
      return Row(
        children: [
          GestureDetector(
            onTap: _isSubmitting ? null : () => _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut),
            child: Image.asset('assets/buttons/navigation/pixel/left_small_light.png', width: 24, height: 24),
          ),
          const Spacer(),
          AppButton(
            variant: AppButtonVariant.text,
            text: 'Submit',
            onPressed: _isSubmitting ? () {} : _submitReflection,
            backgroundColor: _isSubmitting ? AppColors.scale : null,
            borderColor: _isSubmitting ? AppColors.textDisabled : null,
            textColor: _isSubmitting ? AppColors.textDisabled : null,
          ),
        ],
      );
    }

    return Row(
      children: [
        _currentPage > 0
        ? GestureDetector(
            onTap: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 250), curve: Curves.easeInOut),
            child: Image.asset('assets/buttons/navigation/pixel/left_small_light.png', width: 24, height: 24),
          )
        : const SizedBox(width: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index <= _currentPage
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _canGoNext 
              ? () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 250), curve: Curves.easeInOut)
              : null,
          child: Image.asset(
            _canGoNext 
                ? 'assets/buttons/navigation/pixel/right_small_light.png' 
                : 'assets/buttons/navigation/pixel/gray_right_small_light.png',
            width: 24, 
            height: 24,
          ),
        ),
      ],
    );
  }
}
