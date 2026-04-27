abstract class MissionEvent {
  const MissionEvent();
}

/// Fetch the user's active missions from the backend.
class FetchMyMissions extends MissionEvent {
  /// When true, the bloc will not emit a loading state if missions
  /// are already cached (used for silent pull-to-refresh).
  final bool silent;

  const FetchMyMissions({this.silent = false});
}
