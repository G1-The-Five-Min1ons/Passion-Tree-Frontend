import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_wrapper.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/t_learning_path_wrapper.dart';

class LearningPathRoleEntryPage extends StatefulWidget {
  const LearningPathRoleEntryPage({super.key});

  @override
  State<LearningPathRoleEntryPage> createState() =>
      _LearningPathRoleEntryPageState();
}

class _LearningPathRoleEntryPageState extends State<LearningPathRoleEntryPage> {
  String? _role;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final storedRole = await getIt<IAuthRepository>().getUserRole();
    if (!mounted) return;

    setState(() {
      _role = storedRole?.trim().toLowerCase();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_role == 'teacher') {
      return const TeacherLearningPathWrapper();
    }

    return const LearningPathWrapper();
  }
}
