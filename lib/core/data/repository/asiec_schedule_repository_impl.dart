
import '../../domain/entity/day_entity.dart';
import '../../domain/repository/schedule_repository.dart';
import '../../enums/schedule_request_type.dart';
import '../data_sources/schedule/remote/asiec_schedule_api_service.dart';

class AsiecScheduleRepositoryImpl extends ScheduleRepository {
  final AsiecScheduleApiService _scheduleApiService;

  AsiecScheduleRepositoryImpl(this._scheduleApiService);

  @override
  Stream<DayEntity> getSchedule(DateTime start, int days, ScheduleRequestType type, String id) async* {
    yield* _scheduleApiService.getSchedule(start, days, type, id);
  }
}