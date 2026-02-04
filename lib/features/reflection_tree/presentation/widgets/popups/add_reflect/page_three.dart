import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/radio.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class PageThreeView extends StatefulWidget {
  final int initialProgress;
  final int initialChallenge;
  final Function(int) onProgressChanged;
  final Function(int) onChallengeChanged;

  const PageThreeView({
    super.key,
    required this.initialProgress,
    required this.initialChallenge,
    required this.onProgressChanged,
    required this.onChallengeChanged,
  });

  @override
  State<PageThreeView> createState() => _PageThreeViewState();
}

class _PageThreeViewState extends State<PageThreeView> with AutomaticKeepAliveClientMixin{
  late int _progress;
  late int _challenge;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
    _challenge = widget.initialChallenge;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Learning Progress : ",
          style: AppTypography.titleSemiBold,
          ),
        ),
      
        const SizedBox(height: 60),
        PixelRadioGroup(
          showIndex: true,
          count: 5,
          initialValue: _progress,
          onSelected: (value) {
            setState(() {
              _progress = value;
            });
            widget.onProgressChanged(value);
          },
        ),
        const SizedBox(height: 60),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "How challenging was this : ",
          style: AppTypography.titleSemiBold,
          ),
        ),
        const SizedBox(height: 60),
        PixelRadioGroup(
          showIndex: true,
          count: 5,
          initialValue: _challenge,
          onSelected: (value) {
            setState(() {
              _challenge = value;
            });
            widget.onChallengeChanged(value);
          },
        ),
      ],
    );
  }
}