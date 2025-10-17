import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/get_default_schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/get_local_schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/get_schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/save_local_schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit_states.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_settings.dart';
import 'package:bloc/bloc.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._getDefaultSchedule, this._getSettings,
      this._getLocalSchedule, this._saveLocalSchedule, this._getSchedule)
      : super(ScheduleStateInit());

  final GetDefaultSchedule _getDefaultSchedule;
  final GetSchedule _getSchedule;
  final GetLocalSchedule _getLocalSchedule;
  final SaveLocalSchedule _saveLocalSchedule;
  final GetSettings _getSettings;

  String? _lastRequestId;
  bool isFirstLoad = true;
  DateTime? _selectedDate;

  Future<void> loadDefaultSchedule() async {
    emit(ScheduleStateLoading());
    _selectedDate = null;

    try {
      final settings = await _getSettings();
      final type = settings.requestType;
      final id = settings.requestId;

      if (id.isEmpty) {
        emit(ScheduleStateIdUnselected());
        return;
      }

      final isRequestIdChanged = _lastRequestId != id && !isFirstLoad;
      _lastRequestId = id;
      isFirstLoad = false;

      bool isLocalScheduleEmpty = false;

      if (!isRequestIdChanged) {
        try {
          final localSchedule = await _getLocalSchedule();
          if (localSchedule.days.isNotEmpty) {
            emit(ScheduleStateLoaded(localSchedule, type,
                isLocalSchedule: true));
          } else {
            isLocalScheduleEmpty = true;
          }
        } catch (e) {
          // Продолжаем загрузку сетевого расписания
          isLocalScheduleEmpty = true;
        }
      }

      try {
        final schedule = await _getDefaultSchedule(type, id);

        if (schedule.days.isNotEmpty) {
          await _saveLocalSchedule(schedule);
          emit(ScheduleStateLoaded(schedule, type));
        } else {
          emit(ScheduleStateEmpty());
        }
      } catch (e) {
        if (isLocalScheduleEmpty) {
          emit(ScheduleStateError(e.toString()));
        }
      }
    } catch (e) {
      emit(ScheduleStateError(e.toString()));
    }
  }

  Future<void> loadSchedule(DateTime date) async {
    emit(ScheduleStateLoading());
    _selectedDate = date;

    try {
      final settings = await _getSettings();

      if (settings.requestId.isEmpty) {
        await loadDefaultSchedule();
      }

      final schedule =
          await _getSchedule(settings.requestType, settings.requestId, date);
      emit(ScheduleStateLoadedByDate(schedule, settings.requestType));
    } catch (e) {
      await loadDefaultSchedule();
    }
  }

  bool get isDateSelected => _selectedDate != null;

  DateTime? get selectedDate => _selectedDate;
}
