import 'package:asiec_schedule/core/domain/entity/lesson.dart';

class Day {
  final DateTime date;
  final List<Lesson> lessons;

  Day({required this.date, required this.lessons});

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }

  // Создание из JSON
  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      date: DateTime.parse(json['date'] as String),
      lessons: (json['lessons'] as List)
          .map((lessonJson) =>
              Lesson.fromJson(lessonJson as Map<String, dynamic>))
          .toList(),
    );
  }
}
