import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/entities/album_model.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/utils/date_time_formatter.dart';

class AlbumMapper {
  /// Convert AlbumApiModel to Album (Domain Model)
  static Album toAlbum(AlbumApiModel apiModel, {List<AlbumItem>? items}) {
    return Album(
      albumId: apiModel.albumId,
      title: apiModel.albumName,
      subtitle: _formatSubtitle(apiModel.lastEdit),
      image: apiModel.coverImageUrl,
      items: items,
    );
  }

  /// Convert list of AlbumApiModel to list of Album
  static List<Album> toAlbumList(List<AlbumApiModel> apiModels) {
    return apiModels.map((apiModel) => toAlbum(apiModel)).toList();
  }

  /// Format subtitle with tree count and last edit date
  static String _formatSubtitle(DateTime lastEdit) {
    final relativeTime = DateTimeFormatter.getRelativeTime(lastEdit);
    return 'Edited $relativeTime';
  }



  /// Convert AlbumApiModel to Album with full details including items
  static Album toAlbumWithItems(
    AlbumApiModel apiModel,
    List<AlbumItem> items,
  ) {
    return toAlbum(apiModel, items: items);
  }
}
