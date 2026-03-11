import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_reflect/page._two.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_reflect/page_one.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_reflect/page_three.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/add_reflect/reflection_overview.dart';

class AddReflectPopup extends StatefulWidget {
  final String nodeName;

  const AddReflectPopup({super.key, required this.nodeName});

  static void show(BuildContext context, {required String nodeName}) {
    showDialog(
      context: context,
      builder: (context) => AddReflectPopup(nodeName: nodeName),
    );
  }

  @override
  State<AddReflectPopup> createState() => _AddReflectPopupState();
}

class _AddReflectPopupState extends State<AddReflectPopup> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  //TODO: จัดการ state
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
        ],
      ),
    );
  }

  Widget _buildStepBar() {
    if (_currentPage == 3) {
      return Row(
        children: [
          GestureDetector(
            onTap: () => _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut),
            child: Image.asset('assets/buttons/navigation/pixel/left_small_light.png', width: 24, height: 24),
          ),
          const Spacer(),
          AppButton(
              variant: AppButtonVariant.text,
              text: 'Submit',
              onPressed: () {
                //TODO save to db
              },
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