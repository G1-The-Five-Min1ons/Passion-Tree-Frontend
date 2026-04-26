import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/homebar.dart';
import 'package:passion_tree_frontend/core/common_widgets/layout/app_background.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/services/startup_prefetch_service.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';

class PostLoginBootstrapPage extends StatefulWidget {
  const PostLoginBootstrapPage({super.key});

  @override
  State<PostLoginBootstrapPage> createState() => _PostLoginBootstrapPageState();
}

class _PostLoginBootstrapPageState extends State<PostLoginBootstrapPage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    try {
      final service = getIt<StartupPrefetchService>();
      await service.runInOrder(
        learningPathBloc: context.read<LearningPathBloc>(),
        albumBloc: context.read<AlbumBloc>(),
      );
    } catch (_) {
      // Proceed to home even if some prefetch calls fail.
    }

    if (!mounted) return;
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return const HomeBarWidget(enableStartupPrefetch: false);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/tree_icon.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 24),
              Text(
                'Passion Tree',
                style: AppPixelTypography.h2.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
