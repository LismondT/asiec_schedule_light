
import 'package:asiec_schedule/core/domain/entity/day_entity.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

abstract class ScheduleRepository {
  Stream<DayEntity> getSchedule(DateTime start, int days, ScheduleRequestType type, String id);
}