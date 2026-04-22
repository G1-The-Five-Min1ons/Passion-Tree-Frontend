import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/more_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/album_base_card.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/main_tree_image.dart';
import 'package:passion_tree_frontend/core/common_widgets/popups/action_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/edit_tree_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/pause_period.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/retrieve_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/resume_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/tree_status_popup.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_bloc.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/bloc/album_event.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';

class TreeAlbumCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final Widget dataDisplay;
  final String treeStatus;
  final double? treeScore;
  final String currentAlbumname;
  final List<String> albumOptions;
  final List<Album> availableAlbums;
  final String treeId;
  final String albumId;
  final bool isReflectionClosed;
  final VoidCallback? onStatusTap;
  final VoidCallback? onCardTap;
  final VoidCallback? onDelete;
  final bool isPaused;
  final String? pauseFrom;
  final String? pauseTo;
  final String? resumeOn;

  const TreeAlbumCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.dataDisplay,
    required this.treeStatus,
    this.treeScore,
    required this.currentAlbumname,
    required this.albumOptions,
    required this.availableAlbums,
    required this.treeId,
    required this.albumId,
    this.isReflectionClosed = false,
    this.onStatusTap,
    this.onCardTap,
    this.onDelete,
    this.isPaused = false,
    this.pauseFrom,
    this.pauseTo,
    this.resumeOn,
  });

  String _capitalizeStatus(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return trimmedValue;
    }
    return '${trimmedValue[0].toUpperCase()}${trimmedValue.substring(1)}';
  }

  bool _isDiedStatus(String value) {
    return value.trim().toLowerCase() == 'died';
  }

  String _normalizedStatus(String value) {
    return value.trim().toLowerCase();
  }

  String _normalizedName(String value) {
    return value.trim().toLowerCase();
  }

  String? _findAlbumIdByTitle(String selectedAlbumName) {
    final normalizedSelected = _normalizedName(selectedAlbumName);
    for (final album in availableAlbums) {
      if (_normalizedName(album.title) == normalizedSelected) {
        return album.albumId;
      }
    }
    return null;
  }

  DateTime? _toDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  DateTime? _parseDdMmYyyy(String raw) {
    final parts = raw.split('/');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }

    return _toDateOnly(parsed);
  }

  DateTime? _parseDisplayDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final raw = value.trim();

    final displayDate = _parseDdMmYyyy(raw);
    if (displayDate != null) {
      return displayDate;
    }

    final isoDate = DateTime.tryParse(raw);
    if (isoDate != null) {
      return _toDateOnly(isoDate.toLocal());
    }

    return null;
  }

  bool _isFutureDisplayDate(String? value) {
    final parsedDate = _parseDisplayDate(value);
    if (parsedDate == null) {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return parsedDate.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    final bool isTreePaused = isPaused;
    final bool isBeforePauseStart = _isFutureDisplayDate(pauseFrom);
    final bool hasPendingPauseWindow = _isFutureDisplayDate(resumeOn);
    final bool shouldBlockPauseAction =
        isTreePaused || isBeforePauseStart || hasPendingPauseWindow;
    return Stack(
      children: [
        GestureDetector(
          onTap: isTreePaused ? null : onCardTap,
          child: PixelBaseCard(
            title: title,
            subtitle: subtitle,
            actionIcon: IconButton(
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              splashRadius: 20,
              icon: const MoreIcon(),
              onPressed: () {
                ActionPopUp.show(
                  context,
                  onEdit: () {
                    EditTreePopUp.show(
                      context,
                      initialName: title,
                      initialPath: currentAlbumname,
                      pathOptions: albumOptions.isEmpty
                          ? ['No albums available']
                          : albumOptions,
                      onSave: (newTitle, selectedAlbumName) {
                        String? newAlbumId;
                        if (_normalizedName(selectedAlbumName) !=
                                _normalizedName(currentAlbumname) &&
                            availableAlbums.isNotEmpty) {
                          newAlbumId = _findAlbumIdByTitle(selectedAlbumName);
                        }

                        context.read<AlbumBloc>().add(
                          UpdateTreeEvent(
                            treeId: treeId,
                            albumId: albumId,
                            title: newTitle,
                            newAlbumId: newAlbumId,
                          ),
                        );
                      },
                    );
                  },
                  onDelete: () {
                    onDelete?.call();
                  },
                );
              },
            ),
            topContent: Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColors.surface,
              child: Stack(
                children: [
                  Center(
                    child: MainTreeImage(
                      status: treeStatus,
                      treeScore: treeScore,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isReflectionClosed)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (shouldBlockPauseAction) {
                  PausePeriod.show(
                    context,
                    pauseFrom: pauseFrom,
                    pauseTo: pauseTo,
                  );
                  return;
                }

                final normalizedStatus = _normalizedStatus(statusText);

                if (_isDiedStatus(statusText)) {
                  RetrievePopup.show(
                    context,
                    onConfirm: () {
                      context.read<AlbumBloc>().add(
                        RetrieveTreeEvent(treeId: treeId, albumId: albumId),
                      );
                    },
                  );
                  return;
                }

                if (['growing', 'fading', 'dying'].contains(normalizedStatus)) {
                  TreeStatusPopup.show(
                    context,
                    normalizedStatus,
                    onPauseSelected: (pauseFrom, resumeOn) {
                      context.read<AlbumBloc>().add(
                        PauseTreeEvent(
                          treeId: treeId,
                          albumId: albumId,
                          pauseFrom: pauseFrom,
                          resumeOn: resumeOn,
                        ),
                      );
                    },
                  );
                  return;
                }

                onStatusTap?.call();
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _capitalizeStatus(statusText),
                    textAlign: TextAlign.center,
                    style: AppPixelTypography.littleSmall.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (isTreePaused)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                ResumePopup.show(
                  context,
                  onResume: () {
                    context.read<AlbumBloc>().add(
                      ResumeTreeEvent(treeId: treeId, albumId: albumId),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textDisabled.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Paused",
                      style: AppPixelTypography.smallTitle.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Resume on : ${resumeOn ?? '-'}",
                      style: AppTypography.smallBodyRegular.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
