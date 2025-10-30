import 'package:asiec_schedule/core/domain/entity/day.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/repository/schedule_repository.dart';

class GetCurrentDay {
  final ScheduleRepository _repository;

  GetCurrentDay(this._repository);

  Future<Day?> call() async {
    try {
      final schedule = await _repository.getLocalSchedule();

      if (schedule.days.isEmpty) {
        return null;
      }

      final currentDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      for (final day in schedule.days) {
        final dayDate = DateTime(
          day.date.year,
          day.date.month,
          day.date.day,
        );

        if (dayDate.isAtSameMomentAs(currentDate)) {
          return day;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
