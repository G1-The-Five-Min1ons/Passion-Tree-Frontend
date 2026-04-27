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
    LogHandler.separator(title: 'SETTING REMOTE · GET ALL');

    final response = await _apiHandler.get(
      url: ApiConfig.settings,
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (!response.isSuccess) {
      _handleApiError(response, 'GET SETTINGS');
      throw createExceptionFromStatusCode(
        response.statusCode,
        response.error ?? response.message ?? 'Failed to get settings',
      );
    }

    try {
      final rawData = response.data;
      List<dynamic> rawList = [];

      if (rawData is List) {
        rawList = rawData;
      } else if (rawData is Map && rawData.containsKey('data')) {
        rawList = rawData['data'] as List? ?? [];
      }

      final settings = rawList
          .whereType<Map>()
          .map((item) => SettingItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      LogHandler.success('Successfully parsed ${settings.length} settings');
      return settings;
    } catch (e, stackTrace) {
      LogHandler.error(
        'SETTING REMOTE · PARSE ERROR: โครงสร้าง JSON ไม่ตรงกับ Model',
        error: e,
        stackTrace: stackTrace,
      );
      throw ParseException(message: 'Failed to parse settings data: $e');
    }
  }

  @override
  Future<void> updateSetting({
    required String token,
    required String key,
    required String value,
  }) async {
    LogHandler.separator(title: 'SETTING REMOTE · UPDATE');

    final response = await _apiHandler.put(
      url: ApiConfig.settingByKey(key),
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode({'value': value}),
      timeout: ApiConfig.connectionTimeout,
    );

    if (!response.isSuccess) {
      _handleApiError(response, 'UPDATE SETTING ($key)');
      throw createExceptionFromStatusCode(
        response.statusCode,
        response.error ?? response.message ?? 'Failed to update setting',
      );
    }

    LogHandler.success('Setting $key updated successfully');
  }

  //  Helper Method handle Error
  void _handleApiError(ApiResponse response, String context) {
    final message = 'status=${response.statusCode}, message=${response.error ?? response.message}';
    
    if (response.statusCode >= 400 && response.statusCode < 500) {
      LogHandler.warning('SETTING REMOTE · $context: $message');
    } else {
      LogHandler.error('SETTING REMOTE · $context: $message');
    }
  }
}