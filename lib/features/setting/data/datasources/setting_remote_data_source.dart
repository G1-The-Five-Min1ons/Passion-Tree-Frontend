import 'dart:convert';

import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/core/network/api_handler.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/setting/data/models/setting_item_model.dart';

abstract class SettingRemoteDataSource {
  Future<List<SettingItemModel>> getSettings(String token);
  Future<void> updateSetting({
    required String token,
    required String key,
    required String value,
  });
}

class SettingRemoteDataSourceImpl implements SettingRemoteDataSource {
  final ApiHandler _apiHandler;

  SettingRemoteDataSourceImpl({ApiHandler? apiHandler})
    : _apiHandler = apiHandler ?? ApiHandler();

  @override
  Future<List<SettingItemModel>> getSettings(String token) async {
    final response = await _apiHandler.get(
      url: ApiConfig.settings,
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (!response.isSuccess) {
      LogHandler.error(
        'SETTING REMOTE · GET SETTINGS failed: '
        'status=${response.statusCode}, message=${response.error ?? response.message}',
      );
      throw createExceptionFromStatusCode(
        response.statusCode,
        response.error ?? response.message ?? 'Failed to get settings',
      );
    }

    final rawList = (response.data is List)
        ? response.data as List
        : <dynamic>[];

    return rawList
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .map(SettingItemModel.fromJson)
      .toList();
  }

  @override
  Future<void> updateSetting({
    required String token,
    required String key,
    required String value,
  }) async {
    final response = await _apiHandler.put(
      url: ApiConfig.settingByKey(key),
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode({'value': value}),
      timeout: ApiConfig.connectionTimeout,
    );

    if (!response.isSuccess) {
      LogHandler.error(
        'SETTING REMOTE · UPDATE failed: '
        'status=${response.statusCode}, key=$key, message=${response.error ?? response.message}',
      );
      throw createExceptionFromStatusCode(
        response.statusCode,
        response.error ?? response.message ?? 'Failed to update setting',
      );
    }
  }
}
