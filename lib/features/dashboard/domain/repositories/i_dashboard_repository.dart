import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

abstract class IDashboardRepository {
  /// Fetch full dashboard data for the currently authenticated user
  Future<DashboardResponse> getDashboard();
}
