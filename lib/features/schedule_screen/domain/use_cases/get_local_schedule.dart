import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/repository/schedule_repository.dart';

class GetLocalSchedule {
  final ScheduleRepository _repository;

  GetLocalSchedule(this._repository);

  Future<ScheduleEntity> call({bool startByToday = true}) async {
    final schedule = await _repository.getLocalSchedule();

    if (!startByToday) {
      return schedule;
    }

    final today = DateTime.now();
    final trimmedSchedule = ScheduleEntity(
        firstDate: today,
        lastDate: schedule.lastDate,
        days:
            schedule.days.skipWhile((day) => day.date.isAfter(today)).toList());

    return trimmedSchedule;
  }
}
