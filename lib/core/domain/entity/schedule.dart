import 'package:asiec_schedule/core/domain/entity/day.dart';

class Schedule {
  final DateTime firstDate;
  final DateTime lastDate;
  final List<Day> days;

  Schedule({
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

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      firstDate: DateTime.parse(json['firstDate'] as String),
      lastDate: DateTime.parse(json['lastDate'] as String),
      days: (json['days'] as List)
          .map((dayJson) => Day.fromJson(dayJson as Map<String, dynamic>))
          .toList(),
    );
  }
}
