import 'dart:async';

import 'package:asiec_schedule/core/domain/entity/day_entity.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/get_default_schedule_use_case.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/bloc/schedule/remote/remote_schedule_events.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/bloc/schedule/remote/remote_schedule_state.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_settings.dart';
import 'package:bloc/bloc.dart';

class RemoteScheduleBloc
    extends Bloc<RemoteScheduleEvent, RemoteScheduleState> {
  final GetDefaultScheduleUseCase _getDefaultScheduleUseCase;
  final GetSettingsUseCase _getSettings;

  final List<DayEntity> _items = [];
  late ScheduleRequestType _requestType;
  late String _requestId;
  StreamController<List<DayEntity>> scheduleController =
      StreamController<List<DayEntity>>.broadcast();

  DayEntity? get currentDay => _items.isNotEmpty ? _items[0] : null;

  void clearItems() => _items.clear();

  RemoteScheduleBloc(this._getDefaultScheduleUseCase, this._getSettings)
      : super(const RemoteScheduleLoading()) {
    on<InitializeScheduleEvent>(onInitialize);
    on<GetDefaultScheduleEvent>(onGetDefaultSchedule);
    on<RequestDataSchangedEvent>(onRequestDataChanged);
  }

  void onInitialize(
      InitializeScheduleEvent event, Emitter<RemoteScheduleState> emit) async {
    emit(RemoteScheduleLoading());
    final settings = await _getSettings();
    _requestType = settings.requestType;
    _requestId = settings.requestId;

    if (_requestId.isEmpty) {
      emit(RemoteScheduleWithoutId());
    } else {
      add(GetDefaultScheduleEvent());
    }
  }

  void onGetDefaultSchedule(
      GetDefaultScheduleEvent event, Emitter<RemoteScheduleState> emit) async {
    if (_requestId == '') {
      emit(RemoteScheduleWithoutId());
      return;
    }

    emit(RemoteScheduleLoading());

    final Stream<DayEntity> stream =
        await _getDefaultScheduleUseCase(_requestType, _requestId);

    stream.listen((item) {
      _items.add(item);
      scheduleController.sink.add(_items);
    }).onError(() => emit(RemoteScheduleError(
        'При попытке получить данные расписания взникла ошибка')));

    emit(RemoteScheduleDone(scheduleController: scheduleController));
  }

  void onRequestDataChanged(
      RequestDataSchangedEvent event, Emitter<RemoteScheduleState> emit) {
    _requestType = event.requestType;
    _requestId = event.requestId;

    if (_requestId == '') {
      emit(RemoteScheduleWithoutId());
      _items.clear();
      scheduleController.sink.add(_items);
      return;
    }

    add(GetDefaultScheduleEvent());
  }
}
