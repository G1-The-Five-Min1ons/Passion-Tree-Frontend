import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/mission/data/models/user_mission_model.dart';
import 'package:passion_tree_frontend/features/mission/domain/usecases/get_my_missions_usecase.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_event.dart';
import 'package:passion_tree_frontend/features/mission/presentation/bloc/mission_state.dart';

class MissionBloc extends Bloc<MissionEvent, MissionState> {
  final GetMyMissionsUseCase _getMyMissions;

  MissionBloc({required GetMyMissionsUseCase getMyMissions})
      : _getMyMissions = getMyMissions,
        super(const MissionInitial()) {
    // droppable: ignore additional FetchMyMissions while one is in flight,
    // so the outer + inner MissionBlocProvider don't double-fetch.
    on<FetchMyMissions>(_onFetchMyMissions, transformer: droppable());
  }

  Future<void> _onFetchMyMissions(
    FetchMyMissions event,
    Emitter<MissionState> emit,
  ) async {
    final current = state;
    final List<UserMissionModel> previous;
    if (current is MissionLoaded) {
      previous = current.missions;
    } else if (current is MissionError) {
      previous = current.previousMissions;
    } else {
      previous = const <UserMissionModel>[];
    }

    if (!event.silent || current is! MissionLoaded) {
      emit(const MissionLoading());
    }

    try {
      final missions = await _getMyMissions.execute();
      LogHandler.success('[MissionBloc] loaded ${missions.length} missions');
      emit(MissionLoaded(missions));
    } catch (e, st) {
      LogHandler.error('[MissionBloc] fetch failed', error: e, stackTrace: st);
      emit(
        MissionError(
          e.toString(),
          previousMissions: List<UserMissionModel>.unmodifiable(previous),
        ),
      );
    }
  }
}
