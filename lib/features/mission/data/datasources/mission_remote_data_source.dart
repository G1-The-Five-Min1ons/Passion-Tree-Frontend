import 'dart:convert';
import 'dart:math';

import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/core/network/api_handler.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';

abstract class MissionRemoteDataSource {
  /// GET /api/v1/user/missions — returns the active missions of the
  /// authenticated user.
  Future<List<UserMissionModel>> getMyMissions(String token);
}

class MissionRemoteDataSourceImpl implements MissionRemoteDataSource {
  final ApiHandler _apiHandler;

  MissionRemoteDataSourceImpl({required ApiHandler apiHandler})
    : _apiHandler = apiHandler;

  String _generateClientRequestId() {
    final now = DateTime.now().toUtc();
    final rand = Random.secure().nextInt(1 << 20).toRadixString(16);
    return 'mission-${now.microsecondsSinceEpoch}-$rand';
  }

  /// Mask sensitive header values (e.g. Authorization tokens) for safe logging.
  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = <String, String>{};
    headers.forEach((key, value) {
      final lower = key.toLowerCase();
      if (lower == 'authorization' ||
          lower == 'cookie' ||
          lower == 'x-api-key') {
        if (value.length <= 12) {
          sanitized[key] = '***';
        } else {
          // Keep enough context to debug while masking the secret part.
          sanitized[key] =
              '${value.substring(0, 12)}...${value.substring(value.length - 4)}';
        }
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  /// Pretty-print a payload for logs, falling back to toString() if JSON
  /// encoding fails (e.g. non-serializable types).
  String _prettyPayload(dynamic data) {
    if (data == null) return 'null';
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  @override
  Future<List<UserMissionModel>> getMyMissions(String token) async {
    LogHandler.separator(title: 'MISSION REMOTE · GET MY MISSIONS');

    final url = ApiConfig.userMissions;
    final clientRequestId = _generateClientRequestId();
    final headers = <String, String>{
      ...ApiConfig.getAuthHeaders(token),
      'X-Client-Request-Id': clientRequestId,
    };
    final timeout = ApiConfig.connectionTimeout;
    final stopwatch = Stopwatch()..start();

    // ── REQUEST LOG ────────────────────────────────────────────────
    LogHandler.success(
      '[MissionRemote] → REQUEST  GET $url\n'
      '  client_request_id: $clientRequestId\n'
      '  headers: ${_sanitizeHeaders(headers)}\n'
      '  timeout: ${timeout.inSeconds}s',
    );

    final response = await _apiHandler.get(
      url: url,
      headers: headers,
      timeout: timeout,
    );

    stopwatch.stop();

    // ── RESPONSE LOG ───────────────────────────────────────────────
    final responseSummary =
        '[MissionRemote] ← RESPONSE status=${response.statusCode} '
        'success=${response.isSuccess} '
        'elapsed=${stopwatch.elapsedMilliseconds}ms'
        '\n  client_request_id: $clientRequestId'
        '${response.message != null ? '\n  message: ${response.message}' : ''}'
        '${response.error != null ? '\n  error: ${response.error}' : ''}'
        '\n  body: ${_prettyPayload(response.data)}';

    if (response.isSuccess) {
      LogHandler.success(responseSummary);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      LogHandler.warning(responseSummary);
    } else {
      LogHandler.error(responseSummary);
    }

    if (!response.isSuccess) {
      final msg =
          response.error ?? response.message ?? 'Failed to load user missions';
      if (response.statusCode >= 400 && response.statusCode < 500) {
        LogHandler.warning('getMyMissions validation failed: $msg');
      } else {
        LogHandler.error('getMyMissions system failure: $msg');
      }
      throw createExceptionFromStatusCode(response.statusCode, msg);
    }

    try {
      final raw = response.data;
      List<dynamic> rawList = const [];

      if (raw is List) {
        rawList = raw;
      } else if (raw is Map && raw['data'] is List) {
        rawList = raw['data'] as List;
      }

      final missions = rawList
          .whereType<Map>()
          .map((e) => UserMissionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      LogHandler.success(
        '[MissionRemote] ✓ Parsed ${missions.length} user missions '
        '(raw items: ${rawList.length})',
      );
      return missions;
    } catch (e, st) {
      LogHandler.error(
        'MISSION REMOTE · PARSE ERROR',
        error: e,
        stackTrace: st,
      );
      throw ParseException(message: 'Failed to parse user missions: $e');
    }
  }
}
