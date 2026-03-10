class SettingItemModel {
  final String key;
  final String value;

  const SettingItemModel({
    required this.key,
    required this.value,
  });

  factory SettingItemModel.fromJson(Map<String, dynamic> json) {
    return SettingItemModel(
      key: (json['key'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
    );
  }
}
