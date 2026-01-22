import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/searchdropdown.dart';

class AddReflectPage extends StatefulWidget{
  const AddReflectPage ({super.key});

  @override
  State<AddReflectPage> createState() => _AddReflectPageState();
}

class _AddReflectPageState extends State<AddReflectPage>{
  final SearchController _categoryController = SearchController();
  final List<String> _subjects = ['Biology', 'Physics', 'Chemistry', 'Mathematics', 'Computer Science'];

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Reflection Tree', 
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context), 
      ), 
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xmargin),
        child: ListView(
          padding: const EdgeInsets.only(top: AppSpacing.ymargin),
          children: [
              Text(
              "Create\nNew Tree",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),

            const SizedBox(height: 30),
            SearchDropdown(
              options: _subjects,
              label: "From LearningPath Enrollments",
              controller: _categoryController,
              onSelected: (selectedItem) {
              FocusScope.of(context).unfocus();
            },
            ),

            const SizedBox(height: 40),
            Text(
              "Dificulties",
                style: AppPixelTypography.title.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}