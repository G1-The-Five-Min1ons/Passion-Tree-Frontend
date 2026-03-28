import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/error/exceptions.dart';
import 'package:passion_tree_frontend/core/network/api_handler.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

abstract class DashboardRemoteDataSource {
  /// Fetch aggregated dashboard data for the authenticated user
  Future<DashboardResponse> getDashboard(String token);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiHandler _apiHandler;

  DashboardRemoteDataSourceImpl({required ApiHandler apiHandler})
      : _apiHandler = apiHandler;

  @override
  Future<DashboardResponse> getDashboard(String token) async {
    LogHandler.separator(title: 'DASHBOARD REMOTE · GET DASHBOARD');

    final response = await _apiHandler.get(
      url: ApiConfig.dashboard,
      headers: ApiConfig.getAuthHeaders(token),
      timeout: ApiConfig.connectionTimeout,
    );

    if (response.isSuccess && response.data != null) {
      LogHandler.success('getDashboard successful');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return DashboardResponse.fromJson(data);
      }
      throw ParseException(
        message:
            'Expected Map<String, dynamic> for dashboard data but received ${data.runtimeType}',
      );
    }

    // Handle error
    final msg = response.error ?? response.message ?? 'Failed to load dashboard';
    if (response.statusCode >= 400 && response.statusCode < 500) {
      LogHandler.warning('getDashboard validation failed: $msg');
    } else {
      LogHandler.error('getDashboard system failure: $msg');
    }
    throw AuthException(message: msg, statusCode: response.statusCode);
  }
}
