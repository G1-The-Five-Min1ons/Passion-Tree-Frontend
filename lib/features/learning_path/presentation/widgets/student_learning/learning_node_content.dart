import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/material.dart' as lp;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

class LearningNodeContent extends StatefulWidget {
  final String title;
  final String description;
  final List<lp.Material> materials;
  final VoidCallback onStartLearning;
  final VoidCallback onTakeQuiz;
  final String status;
  final String? videoUrl;
  final YoutubePlayerController? controller;
  final Widget? player;

  const LearningNodeContent({
    super.key,
    required this.title,
    required this.description,
    required this.materials,
    required this.onStartLearning,
    required this.onTakeQuiz,
    required this.status,
    this.videoUrl,
    this.controller,
    this.player,
  });

  @override
  State<LearningNodeContent> createState() => _LearningNodeContentState();
}

class _LearningNodeContentState extends State<LearningNodeContent> {
  String? _videoId;
  bool _showPlayer = false;
  bool _hasStartedLearning = false;

  @override
  void initState() {
    super.initState();
    final videoUrl = widget.videoUrl ?? 'https://youtu.be/Yf4M3WZilRI?si=HU_zfUG1GzGMizNb';
    _videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? '';
  }

  void _initializePlayer() {
    if (widget.controller != null) {
      widget.controller!.play();
      setState(() => _showPlayer = true);

      if (!_hasStartedLearning) {
        _hasStartedLearning = true;
        widget.onStartLearning();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasPlaybackStarted =
      (widget.controller?.value.position.inMilliseconds ?? 0) > 0 ||
      (widget.controller?.value.isPlaying ?? false);
    final shouldShowPlayer =
      widget.player != null && (_showPlayer || hasPlaybackStarted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ===== HEADER =====
        SizedBox(
          height: 72,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: colors.onPrimary),
            ),
          ),
        ),

        const SizedBox(height: 24),

        /// ===== VIDEO / COVER =====
        PixelBorderContainer(
          width: double.infinity,
          height: 180,
          borderColor: AppColors.cardBorder,
          fillColor: colors.surface,
          child: shouldShowPlayer
              ? widget.player!
              : GestureDetector(
                  onTap: _initializePlayer,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_videoId != null && _videoId!.isNotEmpty)
                        Image.network(
                          'https://img.youtube.com/vi/$_videoId/maxresdefault.jpg',
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              'https://img.youtube.com/vi/$_videoId/hqdefault.jpg',
                              width: double.infinity,
                              height: 240,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: colors.surface,
                                  child: const Center(
                                    child: Icon(Icons.videocam_off, size: 56),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, size: 48, color: Colors.white),
                      ),
                    ],
                  ),
                ),
        ),

        const SizedBox(height: 24),

        /// ===== NODE DESCRIPTION =====
        PixelBorderContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderColor: AppColors.cardBorder,
          fillColor: colors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Node Description', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: AppTypography.bodySemiBold.copyWith(color: colors.onSurface),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        /// ===== LEARNING MATERIALS =====
        PixelBorderContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderColor: AppColors.cardBorder,
          fillColor: colors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Learning Materials', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...widget.materials.map(
                (material) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, size: 16, color: colors.onSurface),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${material.type}: ${material.url}',
                          style: AppTypography.subtitleSemiBold.copyWith(color: colors.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        /// ===== TAKE QUIZ BUTTON =====
        Center(
          child: AppButton(
            variant: AppButtonVariant.text,
            text: 'Take Quiz',
            onPressed: () {
              if (widget.status.toLowerCase() == 'active') {
                widget.onTakeQuiz();
              } else {
                widget.onStartLearning();
              }
            },
          ),
        ),
      ],
    );
  }
}
