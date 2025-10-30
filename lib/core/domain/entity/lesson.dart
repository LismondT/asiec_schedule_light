import 'package:asiec_schedule/core/domain/entity/subgroup_data.dart';
import 'package:flutter/material.dart';

class Lesson {
  /// Номер занятия
  final int number;

  /// Название занятия
  final String? name;

  /// Группа
  final String? group;

  /// Преподаватель
  final String? teacher;

  /// Аудитория
  final String? classroom;

  /// Корпус
  final String? territory;

  /// Подгруппа занятия (0, если занятие не делится на подгруппы)
  final int subgroup;

  /// Если занятие двух подгрупп проходят в одно время
  final SubgroupData? subgroupData;

  /// Время начала занятий
  final TimeOfDay startTime;

  /// Время окончания занятий
  final TimeOfDay endTime;

  /// Дата занятия
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

  const Lesson(
      {required this.number,
      required this.name,
      required this.group,
      required this.subgroup,
      required this.teacher,
      required this.classroom,
      required this.territory,
      required this.startTime,
      required this.endTime,
      required this.date,
      this.subgroupData});

  Lesson copyWith(
      {int? number,
      String? name,
      String? group,
      int? subgroup,
      SubgroupData? subgroupData,
      String? teacher,
      String? classroom,
      String? territory,
      TimeOfDay? startTime,
      TimeOfDay? endTime,
      DateTime? date}) {
    return Lesson(
        number: number ?? this.number,
        name: name ?? this.name,
        group: group ?? this.group,
        subgroup: subgroup ?? this.subgroup,
        subgroupData: subgroupData ?? this.subgroupData,
        teacher: teacher ?? this.teacher,
        classroom: classroom ?? this.classroom,
        territory: territory ?? this.territory,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        date: date ?? this.date);
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'group': group,
      'subgroup': subgroup,
      'subgroupData': subgroupData?.toJson(),
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

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      number: json['number'] as int,
      name: json['name'],
      group: json['group'],
      subgroup: json['subgroup'] as int,
      subgroupData: json['subgroupData'] != null
          ? SubgroupData.fromJson(json['subgroupData'] as Map<String, dynamic>)
          : null,
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
