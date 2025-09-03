
import '../../../../domain/entity/day_entity.dart';
import '../../../../enums/schedule_request_type.dart';

abstract class ScheduleApiService {
  Stream<DayEntity> getSchedule(DateTime start, int days, ScheduleRequestType type, String id);
}