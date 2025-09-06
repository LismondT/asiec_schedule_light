import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/get_default_schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit_states.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_settings.dart';
import 'package:bloc/bloc.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._getDefaultSchedule, this._getSettings)
      : super(ScheduleStateInit());

  final GetDefaultSchedule _getDefaultSchedule;
  final GetSettings _getSettings;

  Future<void> loadDefaultSchedule() async {
    emit(ScheduleStateLoading());

    try {
      final settings = await _getSettings();
      final type = settings.requestType;
      final id = settings.requestId;

      if (id.isEmpty) {
        emit(ScheduleStateIdUnselected());
      } else {
        final schedule = await _getDefaultSchedule(type, id);

        if (schedule.days.isEmpty) {
          emit(ScheduleStateEmpty());
        } else {
          emit(ScheduleStateLoaded(schedule));
        }
      }
    } catch (e) {
      emit(ScheduleStateError(e.toString()));
    }
  }
}
