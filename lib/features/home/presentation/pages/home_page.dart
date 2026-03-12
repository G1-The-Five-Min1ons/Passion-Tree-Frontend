import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xmargin,
            right: AppSpacing.xmargin,
            top: AppSpacing.ymargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          ),
        ),
      ),
    );
  }
}
