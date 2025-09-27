import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

import 'dart:convert';

class SettingIdsEntity {
  final Map<String, String> groupIds;
  final Map<String, String> teacherIds;
  final Map<String, String> classroomIds;

  SettingIdsEntity({
    required this.groupIds,
    required this.teacherIds,
    required this.classroomIds,
  });

  Map<String, String> getIds(ScheduleRequestType type) {
    return switch (type) {
      ScheduleRequestType.groups => groupIds,
      ScheduleRequestType.teachers => teacherIds,
      ScheduleRequestType.classrooms => classroomIds,
    };
  }

  // Преобразование объекта в JSON
  Map<String, dynamic> toJson() {
    return {
      'groupIds': groupIds,
      'teacherIds': teacherIds,
      'classroomIds': classroomIds,
    };
  }

  // Преобразование JSON в объект
  factory SettingIdsEntity.fromJson(Map<String, dynamic> json) {
    return SettingIdsEntity(
      groupIds: Map<String, String>.from(json['groupIds'] ?? {}),
      teacherIds: Map<String, String>.from(json['teacherIds'] ?? {}),
      classroomIds: Map<String, String>.from(json['classroomIds'] ?? {}),
    );
  }

  // Дополнительные удобные методы:

  // Преобразование в строку JSON
  String toJsonString() {
    return json.encode(toJson());
  }

  // Создание из строки JSON
  factory SettingIdsEntity.fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return SettingIdsEntity.fromJson(jsonMap);
  }

  // Копирование с изменениями
  SettingIdsEntity copyWith({
    Map<String, String>? groupIds,
    Map<String, String>? teacherIds,
    Map<String, String>? classroomIds,
  }) {
    return SettingIdsEntity(
      groupIds: groupIds ?? this.groupIds,
      teacherIds: teacherIds ?? this.teacherIds,
      classroomIds: classroomIds ?? this.classroomIds,
    );
  }

  @override
  String toString() {
    return 'SettingIdsEntity(groupIds: $groupIds, teacherIds: $teacherIds, classroomIds: $classroomIds)';
  }
}
