import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

abstract class ScheduleRepository {
  Future<ScheduleEntity> getSchedule(
      DateTime start, int days, ScheduleRequestType type, String id);
}
