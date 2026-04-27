import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_bloc.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_event.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_state.dart';

/// Provides the shared singleton [MissionBloc] to its subtree and
/// auto-triggers an initial fetch the first time it is mounted.
///
/// Wrap any subtree (e.g., the home navigation shell) with this widget so
/// both the Home tab and the Profile/Dashboard tab read the same bloc via
/// `context.read<MissionBloc>()` — neither tab needs to dispatch the
/// initial `FetchMyMissions` itself.
class MissionBlocProvider extends StatelessWidget {
  final Widget child;

  const MissionBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bloc = getIt<MissionBloc>();

    // Kick off the first fetch as soon as we get a fresh singleton.
    // Subsequent mounts (e.g., after a tree rebuild) skip this because the
    // state will no longer be MissionInitial.
    if (bloc.state is MissionInitial) {
      bloc.add(const FetchMyMissions());
    }

    // Use BlocProvider.value so the singleton MissionBloc registered in
    // GetIt is reused (and not auto-closed) when this provider is disposed.
    return BlocProvider<MissionBloc>.value(
      value: bloc,
      child: child,
    );
  }
}
