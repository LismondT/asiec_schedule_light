import 'package:asiec_schedule/core/domain/entity/schedule.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

abstract class ScheduleRepository {
  Future<Schedule> getSchedule(
      DateTime start, int days, ScheduleRequestType type, String id);

  Future<Schedule> getLocalSchedule();

  Future<void> saveLocalSchedule(Schedule schedule);
}
