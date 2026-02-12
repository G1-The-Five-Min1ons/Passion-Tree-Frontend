import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/album_model.dart';

class AlbumMapper {
  /// Convert AlbumApiModel to Album (Domain Model)
  static Album toAlbum(AlbumApiModel apiModel, {List<AlbumItem>? items}) {
    return Album(
      title: apiModel.albumName,
      subtitle: _formatSubtitle(apiModel.treeCount, apiModel.lastEdit),
      image: apiModel.coverImageUrl,
      items: items,
    );
  }

  /// Convert list of AlbumApiModel to list of Album
  static List<Album> toAlbumList(List<AlbumApiModel> apiModels) {
    return apiModels.map((apiModel) => toAlbum(apiModel)).toList();
  }

  /// Format subtitle with tree count and last edit date
  static String _formatSubtitle(int treeCount, DateTime lastEdit) {
    final relativeTime = _getRelativeTime(lastEdit);
    return 'Edited $relativeTime';
  }

  /// Get relative time string
  static String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Convert AlbumApiModel to Album with full details including items
  static Album toAlbumWithItems(
    AlbumApiModel apiModel,
    List<AlbumItem> items,
  ) {
    return Album(
      title: apiModel.albumName,
      subtitle: _formatSubtitle(apiModel.treeCount, apiModel.lastEdit),
      image: apiModel.coverImageUrl,
      items: items,
    );
  }
}
