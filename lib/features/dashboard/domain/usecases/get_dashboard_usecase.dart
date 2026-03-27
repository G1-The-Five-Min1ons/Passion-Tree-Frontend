import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:passion_tree_frontend/features/dashboard/domain/repositories/i_dashboard_repository.dart';

class GetDashboardUseCase {
  final IDashboardRepository _repository;

  GetDashboardUseCase(this._repository);

  /// Returns the dashboard data or null if an error occurs
  Future<DashboardResponse?> execute() async {
    try {
      return await _repository.getDashboard();
    } catch (e) {
      LogHandler.error('GetDashboardUseCase failed', error: e);
      return null;
    }
  }
}
