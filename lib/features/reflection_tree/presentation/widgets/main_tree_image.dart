import 'package:flutter/material.dart';

class MainTreeImage extends StatelessWidget {
  final String status;
  final double? treeScore;

  const MainTreeImage ({
    super.key,
    required this.status,
    this.treeScore,
  });

  String _normalizeLifecycleStatus(String rawStatus) {
    final normalized = rawStatus.trim().toLowerCase();

    if (normalized.startsWith('growing')) return 'growing';
    if (normalized.startsWith('fading')) return 'fading';
    if (normalized.startsWith('dying')) return 'dying';
    if (normalized.startsWith('died')) return 'died';

    switch (normalized) {
      case 'active':
        return 'growing';
      default:
        return 'growing';
    }
  }

  String _moodFromTreeScore(double? score) {
    if (score == null) return 'happy';
    if (score <= 3.33) return 'dislike';
    if (score <= 6.66) return 'neutral';
    return 'happy';
  }

    @override
    Widget build(BuildContext context) {
      final lifecycleStatus = _normalizeLifecycleStatus(status);
      final moodStatus = _moodFromTreeScore(treeScore);
      final imagePath = 'assets/images/trees/$lifecycleStatus-$moodStatus.png';
    
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 0),
        child: Image.asset(
          imagePath,
          height: 230,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      );
  } 
}