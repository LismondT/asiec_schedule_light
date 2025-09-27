import 'package:asiec_schedule/core/domain/entity/lesson_entity.dart';

class DayEntity {
  final DateTime date;
  final List<LessonEntity> lessons;

  DayEntity({required this.date, required this.lessons});

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }

  // Создание из JSON
  factory DayEntity.fromJson(Map<String, dynamic> json) {
    return DayEntity(
      date: DateTime.parse(json['date'] as String),
      lessons: (json['lessons'] as List)
          .map((lessonJson) =>
              LessonEntity.fromJson(lessonJson as Map<String, dynamic>))
          .toList(),
    );
  }
}
