import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/repository/schedule_repository.dart';

class GetLocalSchedule {
  final ScheduleRepository _repository;

  GetLocalSchedule(this._repository);

  Future<ScheduleEntity> call() async {
    return await _repository.getLocalSchedule();
  }
}
