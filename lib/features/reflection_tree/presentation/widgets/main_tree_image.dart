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
      'growinghappy': 'assets/images/trees/growing-happy.png', //รูปยังใส่ไม่ครบ จะมาใส่ทีหลัง
      'growingneutral': 'assets/images/trees/growing-happy',
      'growingdislike': 'assets/images/trees/growing-happy',
      'fadinghappy': 'assets/images/trees/growing-happy',
      'fadingneutral': 'assets/images/trees/growing-happy',
      'fadingdislike': 'assets/images/trees/growing-happy',
      'dyinghappy': 'assets/images/trees/growing-happy.png',
      'dyingneutral': 'assets/images/trees/growing-happy',
      'dyingdislike': 'assets/images/trees/growing-happy',
      'diedhappy': 'assets/images/trees/growing-happy.png',
      'diedneutral': 'assets/images/trees/growing-happy',
      'dieddislike': 'assets/images/trees/growing-happy',
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