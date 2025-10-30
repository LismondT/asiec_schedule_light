import 'package:asiec_schedule/core/domain/entity/schedule.dart';

abstract class ScheduleLocalDatasource {
  Future<Schedule> getSchedule();

  Future<void> saveSchedule(Schedule schedule);
}
