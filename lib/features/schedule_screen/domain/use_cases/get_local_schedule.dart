import 'package:asiec_schedule/core/domain/entity/schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/repository/schedule_repository.dart';

class GetLocalSchedule {
  final ScheduleRepository _repository;

  GetLocalSchedule(this._repository);

  Future<Schedule> call({bool startByToday = true}) async {
    final schedule = await _repository.getLocalSchedule();

    if (!startByToday) {
      return schedule;
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final trimmedDays = schedule.days
        .where((day) {
      final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
      return !dayDate.isBefore(todayDate);
    })
        .toList();

    return Schedule(
      firstDate: trimmedDays.isNotEmpty ? trimmedDays.first.date : today,
      lastDate: schedule.lastDate,
      days: trimmedDays,
    );
  }
}
