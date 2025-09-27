import 'package:asiec_schedule/core/domain/entity/day_entity.dart';

class ScheduleEntity {
  final DateTime firstDate;
  final DateTime lastDate;
  final List<DayEntity> days;

  ScheduleEntity({
    required this.firstDate,
    required this.lastDate,
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstDate': firstDate.toIso8601String(),
      'lastDate': lastDate.toIso8601String(),
      'days': days.map((day) => day.toJson()).toList(),
    };
  }

  // Создание из JSON
  factory ScheduleEntity.fromJson(Map<String, dynamic> json) {
    return ScheduleEntity(
      firstDate: DateTime.parse(json['firstDate'] as String),
      lastDate: DateTime.parse(json['lastDate'] as String),
      days: (json['days'] as List)
          .map((dayJson) => DayEntity.fromJson(dayJson as Map<String, dynamic>))
          .toList(),
    );
  }
}
