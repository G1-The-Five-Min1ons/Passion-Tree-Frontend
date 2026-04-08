import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/data/datasources/learning_path_data_source.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_api_model.dart';

class RecommendPopup extends StatefulWidget {
  final String treeId;

  const RecommendPopup({required this.treeId, super.key});

  static void show(BuildContext context, {required String treeId}) {
    showDialog(
      context: context,
      builder: (context) => RecommendPopup(treeId: treeId),
    );
  }

  @override
  State<RecommendPopup> createState() => _RecommendPopupState();
}

class _RecommendPopupState extends State<RecommendPopup> {
  late Future<List<LearningPathApiModel>> _recommendedPathsFuture;
  final LearningPathDataSource _dataSource = LearningPathDataSource();

  @override
  void initState() {
    super.initState();
    _recommendedPathsFuture =
        _dataSource.getRecommendedLearningPathsForTree(widget.treeId);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PixelBorderContainer(
        pixelSize: 4,
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "NEXT\nLEARNING PATH",
                      textAlign: TextAlign.center,
                      style: AppPixelTypography.title,
                    ),
                  ),
                  const SizedBox(height: 38),
                  
                  Text(
                    "We recommend you",
                    style: AppTypography.subtitleRegular,
                  ),
                  const SizedBox(height: 16),

                  FutureBuilder<List<LearningPathApiModel>>(
                    future: _recommendedPathsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: SizedBox(
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Failed to load recommendations',
                            style: AppTypography.subtitleRegular.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        );
                      }

                      final recommendedPaths = (snapshot.data ?? []).take(5).toList();

                      if (recommendedPaths.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No recommendations available',
                            style: AppTypography.subtitleRegular.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: recommendedPaths
                            .map((path) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PixelBorderContainer(
                                pixelSize: 3,
                                height: 38,
                                fillColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    path.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.subtitleSemiBold,
                                  ),
                                ),
                              ),
                            ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: -12,
              top: -12,
              child: IconTheme(
                data: const IconThemeData(size: 24),
                child: CloseIcon(
                  color: AppColors.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}