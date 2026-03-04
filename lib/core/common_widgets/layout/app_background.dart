import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';

/// Wraps any page body with an ambient multi-color background
/// inspired by modern dark navy UI with glowing color blobs.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Base dark gradient ─────────────────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.bgGradientTop,   // deep navy top-left
                  AppColors.background,      // darkest bottom-right
                ],
              ),
            ),
          ),
        ),

        // ── Ambient blob: Blue glow — top-right ───────────────────────
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.bgBlobBlue.withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ── Ambient blob: Purple glow — bottom-left ───────────────────
        Positioned(
          bottom: 60,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.bgBlobPurple.withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ── Ambient blob: Teal glow — center-right ────────────────────
        Positioned(
          top: 320,
          right: -60,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.bgBlobBlue.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ── Page content ──────────────────────────────────────────────
        child,
      ],
    );
  }
}

