import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/save_cancel.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

typedef EndReflectingCallback = FutureOr<void> Function();

class EndReflecting extends StatefulWidget {
  final EndReflectingCallback? onConfirm;

  const EndReflecting({super.key, this.onConfirm});

  static Future<void> show(
    BuildContext context, {
    EndReflectingCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EndReflecting(onConfirm: onConfirm),
    );
  }

  @override
  State<EndReflecting> createState() => _EndReflectingState();
}

class _EndReflectingState extends State<EndReflecting> {
  bool _isSubmitting = false;

  Future<void> _handleSave() async {
    if (_isSubmitting) return;

    final callback = widget.onConfirm;
    if (callback == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await Future.sync(callback);

      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route?.isCurrent ?? false) {
        Navigator.of(context).pop();
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 240,
        child: PixelBorderContainer(
          pixelSize: 4,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 56,
                child: Center(
                  child: Text(
                    'Would you like to end this tree?',
                    style: AppPixelTypography.smallTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SaveCancel(
                saveText: _isSubmitting ? 'Yes' : 'Yes',
                cancelText: 'Cancel',
                saveIcon: _isSubmitting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : null,
                onSave: _isSubmitting ? null : _handleSave,
                onCancel: _isSubmitting
                    ? () {}
                    : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
