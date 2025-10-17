import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

class SettingsEntity {
  final bool isDarkMode;
  final ScheduleRequestType requestType;
  final String requestId;
  final bool startSavedScheduleByToday;

  SettingsEntity(
      {required this.isDarkMode,
      required this.requestType,
      required this.requestId,
      required this.startSavedScheduleByToday});
}
