import 'package:asiec_schedule/core/domain/entity/schedule.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/repository/schedule_repository.dart';

//Возвращает стандартное расписание (при открытии приложения или возврате с выбора по дню)
class GetDefaultSchedule {
  final ScheduleRepository _scheduleRepository;

  GetDefaultSchedule(this._scheduleRepository);

  Future<Schedule> call(ScheduleRequestType type, String id) async {
    return await _scheduleRepository.getSchedule(DateTime.now(), 14, type, id);
  }
}
