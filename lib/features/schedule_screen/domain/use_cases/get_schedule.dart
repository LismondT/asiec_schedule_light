import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/injection_container.dart';

import '../repository/schedule_repository.dart';

class GetSchedule {
  final ScheduleRepository _scheduleRepository;

  static const int days = isAltag ? 7 : 21;

  GetSchedule(this._scheduleRepository);

  Future<ScheduleEntity> call(
      ScheduleRequestType type, String id, DateTime date) async {
    return await _scheduleRepository.getSchedule(date, days, type, id);
  }
}
