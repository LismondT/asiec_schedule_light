import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';

abstract class ScheduleLocalDatasource {
  Future<ScheduleEntity> getSchedule();

  Future<void> saveSchedule(ScheduleEntity schedule);
}
