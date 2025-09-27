import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/repository/schedule_repository.dart';

class SaveLocalSchedule {
  final ScheduleRepository _repository;

  SaveLocalSchedule(this._repository);

  Future<void> call(ScheduleEntity schedule) async {
    await _repository.saveLocalSchedule(schedule);
  }
}
