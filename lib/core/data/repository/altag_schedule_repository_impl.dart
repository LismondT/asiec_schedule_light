
import 'package:asiec_schedule/core/data/data_sources/schedule/remote/altag_schedule_api_service.dart';
import 'package:asiec_schedule/core/domain/entity/day_entity.dart';
import 'package:asiec_schedule/core/domain/repository/schedule_repository.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/core/utils/altag/altag_schedule_time_service.dart';

class AltagScheduleRepositoryImpl extends ScheduleRepository {
  final AltagScheduleApiService _scheduleApiService;
  final AltagScheduleTimeService _timeService;

  AltagScheduleRepositoryImpl(this._scheduleApiService, this._timeService);
  
  @override
  Stream<DayEntity> getSchedule(DateTime start, int days, ScheduleRequestType type, String id) async* {
    if (!_timeService.isInitialized) {
      await _timeService.initialize();
    }

    yield* _scheduleApiService.getSchedule(start, days, type, id);
  }
}