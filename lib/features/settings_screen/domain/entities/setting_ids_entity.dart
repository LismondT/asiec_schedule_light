import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

class SettingIdsEntity {
  final Map<String, String> groupIds;
  final Map<String, String> teacherIds;
  final Map<String, String> classroomIds;

  SettingIdsEntity(
      {required this.groupIds,
      required this.teacherIds,
      required this.classroomIds});

  Map<String, String> getIds(ScheduleRequestType type) {
    return switch (type) {
      ScheduleRequestType.groups => groupIds,
      ScheduleRequestType.teachers => teacherIds,
      ScheduleRequestType.classrooms => classroomIds,
    };
  }
}
