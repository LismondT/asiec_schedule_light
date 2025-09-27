import 'package:flutter/material.dart';

class LessonEntity {
  final int number;
  final String? name;
  final String? group;
  final int subgroup;
  final String? teacher;
  final String? classroom;
  final String? territory;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final DateTime? date;

  TimeOfDay duration() {
    // Переводим оба времени в минуты
    int minutes1 = startTime.hour * 60 + startTime.minute;
    int minutes2 = endTime.hour * 60 + endTime.minute;

    // Вычисляем абсолютную разницу в минутах
    int diffMinutes = (minutes1 - minutes2).abs();

    // Конвертируем обратно в часы и минуты
    int hours = diffMinutes ~/ 60;
    int minutes = diffMinutes % 60;

    return TimeOfDay(hour: hours, minute: minutes);
  }

  const LessonEntity({
    required this.number,
    required this.name,
    required this.group,
    required this.subgroup,
    required this.teacher,
    required this.classroom,
    required this.territory,
    required this.startTime,
    required this.endTime,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'group': group,
      'subgroup': subgroup,
      'teacher': teacher,
      'classroom': classroom,
      'territory': territory,
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'date': date?.toIso8601String(),
    };
  }

  // Создание из JSON
  factory LessonEntity.fromJson(Map<String, dynamic> json) {
    return LessonEntity(
      number: json['number'] as int,
      name: json['name'],
      group: json['group'],
      subgroup: json['subgroup'] as int,
      teacher: json['teacher'],
      classroom: json['classroom'],
      territory: json['territory'],
      startTime: TimeOfDay(
        hour: json['startTime']['hour'] as int,
        minute: json['startTime']['minute'] as int,
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'] as int,
        minute: json['endTime']['minute'] as int,
      ),
      date:
          json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    );
  }
}
