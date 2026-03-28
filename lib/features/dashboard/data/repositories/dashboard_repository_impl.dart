import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:passion_tree_frontend/features/dashboard/domain/repositories/i_dashboard_repository.dart';

class DashboardRepositoryImpl implements IDashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  DashboardRepositoryImpl({
    required DashboardRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<DashboardResponse> getDashboard() async {
    final token = await _localDataSource.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }
    return _remoteDataSource.getDashboard(token);
  }
}
