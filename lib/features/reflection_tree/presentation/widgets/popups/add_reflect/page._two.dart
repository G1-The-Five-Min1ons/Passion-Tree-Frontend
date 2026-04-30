import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/common_widgets/selections/radio.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class PageTwoView extends StatefulWidget {
  final Function(int) onScoreChanged;
  final Function(String) onTextChanged;
  final int initialScore;
  final String initialText;
  final String nodeName;

  const PageTwoView({
    super.key,
    required this.onScoreChanged,
    required this.initialScore,
    required this.onTextChanged,
    required this.initialText,
    required this.nodeName,
  });

  @override
  State<PageTwoView> createState() => _PageTwoViewState();
}

class _PageTwoViewState extends State<PageTwoView>
    with AutomaticKeepAliveClientMixin {
  late int _score;

  final List<String> _levelImages = [
    'assets/images/emojis/level_1.png',
    'assets/images/emojis/level_2.png',
    'assets/images/emojis/level_3.png',
    'assets/images/emojis/level_4.png',
    'assets/images/emojis/level_5.png',
  ];

  @override
  void initState() {
    super.initState();
    _score = widget.initialScore;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Node: ${widget.nodeName}',
                      style: AppTypography.h3SemiBold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text("How you feel", style: AppTypography.titleSemiBold),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: _score > 0
                        ? Image.asset(
                            _levelImages[_score - 1],
                            key: ValueKey(_score),
                          )
                        : const Center(child: Text("Please Select")),
                  ),
                  const SizedBox(height: 10),
                  PixelRadioGroup(
                    showIndex: true,
                    count: 5,
                    initialValue: _score,
                    onSelected: (value) {
                      setState(() {
                        _score = value;
                      });
                      widget.onScoreChanged(value);
                    },
                  ),
                  const SizedBox(height: 30),
                  PixelTextField(
                    pixelSize: 3,
                    hintText: 'Reflect on how you feel (Require)',
                    height: 180,
                    value: widget.initialText,
                    onChanged: (val) {
                      widget.onTextChanged(val);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
