import 'package:flutter/material.dart';

class MainTreeImage extends StatelessWidget {
  final String status;

  const MainTreeImage ({
    super.key,
    required this.status,
  });

    @override
    Widget build(BuildContext context) {
      final Map<String, String> statusImages = {
      'growinghappy': 'assets/images/trees/growing-happy.png',
      'growingneutral': 'assets/images/trees/growing-neutral.png',
      'growingdislike': 'assets/images/trees/growing-dislike.png',
      'fadinghappy': 'assets/images/trees/fading-happy.png',
      'fadingneutral': 'assets/images/trees/fading-neutral.png',
      'fadingdislike': 'assets/images/trees/fading-dislike.png',
      'dyinghappy': 'assets/images/trees/dying-happy.png',
      'dyingneutral': 'assets/images/trees/dying-neutral.png',
      'dyingdislike': 'assets/images/trees/dying-dislike.png',
      'diedhappy': 'assets/images/trees/died-happy.png',
      'diedneutral': 'assets/images/trees/died-neutral.png',
      'dieddislike': 'assets/images/trees/died-dislike.png',
      };

      final String? imagePath = statusImages[status.toLowerCase()];

      if (imagePath == null) {
        return const SizedBox.shrink();
      }
    
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