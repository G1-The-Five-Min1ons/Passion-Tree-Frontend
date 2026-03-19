import 'package:passion_tree_frontend/features/setting/data/models/setting_item_model.dart';
import 'package:passion_tree_frontend/features/setting/domain/entities/setting_item.dart';

class SettingMapper {
  static SettingItem toEntity(SettingItemModel model) {
    return SettingItem(key: model.key, value: model.value);
  }
}
