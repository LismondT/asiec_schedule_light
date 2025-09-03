
import 'package:asiec_schedule/core/domain/entity/day_entity.dart';

//ToDo: Хз нужно ли мне это будет
//Вроде нет

class ScheduleEntity {
    final DateTime firstDate;
    final DateTime lastDate;
    final List<DayEntity> days;

    ScheduleEntity({
        required this.firstDate,
        required this.lastDate,
        required this.days,
    });
}