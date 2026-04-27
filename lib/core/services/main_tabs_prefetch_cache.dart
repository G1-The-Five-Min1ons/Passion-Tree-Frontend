import 'package:passion_tree_frontend/features/authentication/domain/entities/user_profile.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/enrolled_learning_path.dart';

class MainTabsPrefetchCache {
  MainTabsPrefetchCache._();

  static final MainTabsPrefetchCache instance = MainTabsPrefetchCache._();

  UserProfile? userProfile;
  DashboardResponse? dashboardData;
  List<EnrolledLearningPath> enrolledPaths = const [];

  bool get hasProfilePayload =>
      userProfile != null || dashboardData != null || enrolledPaths.isNotEmpty;

  void setProfilePayload({
    UserProfile? userProfile,
    DashboardResponse? dashboardData,
    List<EnrolledLearningPath>? enrolledPaths,
  }) {
    this.userProfile = userProfile;
    this.dashboardData = dashboardData;
    this.enrolledPaths = enrolledPaths ?? const [];
  }

  void clear() {
    userProfile = null;
    dashboardData = null;
    enrolledPaths = const [];
  }
}
