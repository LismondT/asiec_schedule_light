
import 'package:asiec_schedule/core/domain/entity/lesson_entity.dart';

class DayEntity {
    final DateTime date;
    final List<LessonEntity> lessons;

    DayEntity({
        required this.date,
        required this.lessons
    });
}