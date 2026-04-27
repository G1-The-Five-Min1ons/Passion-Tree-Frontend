import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/widgets/steps/intro_step.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/widgets/steps/subject_step.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/widgets/steps/knowledge_step.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/widgets/steps/motivation_step.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/widgets/steps/goal_step.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/widgets/steps/reflection_step.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/widgets/steps/learning_style_step.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/features/onboarding/presentation/widgets/onboarding_progress.dart';
import 'package:passion_tree_frontend/features/authentication/presentation/pages/login_page.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int step = 0;

  List<String> subject = [];
  List<String> knowledge = [];
  List<String> motivation = [];
  List<String> goal = [];
  List<String> learningStyle = [];
  List<String> reflection = [];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasOnboarded', true);
    // Save answers as pending to be sent after login
    await prefs.setString('pending_onboarding', jsonEncode({
      'subjects': subject,
      'knowledge_level': knowledge.isNotEmpty ? knowledge.first : '',
      'motivation': motivation.isNotEmpty ? motivation.first : '',
      'daily_goal': goal.isNotEmpty ? goal.first : '',
      'learning_styles': learningStyle,
      'reflection_habit': reflection.isNotEmpty ? reflection.first : '',
    }));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void nextStep() async {
    if (step < 6) {
      setState(() => step++);
    } else {
      await _finishOnboarding();
    }
  }

  bool canProceed() {
    switch (step) {
      case 0:
        return true;
      case 1:
        return subject.isNotEmpty;
      case 2:
        return knowledge.isNotEmpty;
      case 3:
        return motivation.isNotEmpty;
      case 4:
        return goal.isNotEmpty;
      case 5:
        return learningStyle.isNotEmpty;
      case 6:
        return reflection.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (step) {
      case 0:
        content = IntroStep(
          onGetStarted: nextStep,
        );
        break;
      case 1:
        content = SubjectStep(
          selected: subject,
          onSelect: (v) => setState(() => subject = v),
        );
        break;
      case 2:
        content = KnowledgeStep(
          selected: knowledge,
          onSelect: (v) => setState(() => knowledge = v),
        );
        break;
      case 3:
        content = MotivationStep(
          selected: motivation,
          onSelect: (v) => setState(() => motivation = v),
        );
        break;
      case 4:
        content = GoalStep(
          selected: goal,
          onSelect: (v) => setState(() => goal = v),
        );
        break;
      case 5:
        content = LearningStyleStep(
          selected: learningStyle,
          onSelect: (v) => setState(() => learningStyle = v),
        );
        break;
      case 6:
        content = ReflectionStep(
          selected: reflection,
          onSelect: (v) => setState(() => reflection = v),
        );
        break;
      default:
        content = const SizedBox();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (step != 0)
                Align(
                  alignment: Alignment.topRight,
                  child: OnboardingProgress(step: step - 1, total: 6),
                ),
              if (step != 0)
                const SizedBox(height: 32),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: content,
                ),
              ),

              Stack(
                children: [
                  if (step > 0)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        iconSize: 32,
                        onPressed: () {
                          setState(() => step--);
                        },
                      ),
                    ),
                  if (step != 0)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: step == 6
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: canProceed() ? Colors.white : Colors.grey.shade400,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward,
                                    color: canProceed() ? Colors.white : Colors.grey.shade400,
                                  ),
                                  iconSize: 32,
                                  onPressed: canProceed() ? _finishOnboarding : null,
                                ),
                              ],
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.arrow_forward,
                                color: canProceed() ? Colors.white : Colors.grey.shade400,
                              ),
                              iconSize: 32,
                              onPressed: canProceed() ? nextStep : null,
                            ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
