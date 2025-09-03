
import 'package:asiec_schedule/core/domain/entity/day_entity.dart';
import 'package:asiec_schedule/core/domain/repository/schedule_repository.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

//Возвращает стандартное расписание (при открытии приложения или возврате с выбора по дню)
class GetDefaultScheduleUseCase {
  final ScheduleRepository _scheduleRepository;

  GetDefaultScheduleUseCase(this._scheduleRepository);
  
  Future<Stream<DayEntity>> call(ScheduleRequestType type, String id) async {
    return _scheduleRepository.getSchedule(DateTime.now(), 14, type, id);
  }
}