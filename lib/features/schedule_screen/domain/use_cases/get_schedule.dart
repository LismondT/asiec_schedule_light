import 'package:asiec_schedule/core/config/flavor_config.dart';
import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

import '../repository/schedule_repository.dart';

class GetSchedule {
  final ScheduleRepository _scheduleRepository;

  GetSchedule(this._scheduleRepository);

  Future<ScheduleEntity> call(
      ScheduleRequestType type, String id, DateTime date) async {
    int days;

    switch (FlavorConfig.instance.flavor) {
      case AppFlavor.asiec:
        days = 28;
      case AppFlavor.altag:
        days = 7;
    }

    return await _scheduleRepository.getSchedule(date, days, type, id);
  }
}
