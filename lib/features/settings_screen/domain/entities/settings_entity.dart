import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

class SettingsEntity {
  final bool isDarkMode;
  final String themeSeedColor;
  final ScheduleRequestType requestType;
  final String requestId;
  final bool trimSchedule;

  SettingsEntity(
      {required this.isDarkMode,
      required this.themeSeedColor,
      required this.requestType,
      required this.requestId,
      required this.trimSchedule});

  SettingsEntity copyWith(
      {bool? isDarkMode,
      String? themeSeedColor,
      ScheduleRequestType? requestType,
      String? requestId,
      bool? trimSchedule}) {
    return SettingsEntity(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        themeSeedColor: themeSeedColor ?? this.themeSeedColor,
        requestType: requestType ?? this.requestType,
        requestId: requestId ?? this.requestId,
        trimSchedule: trimSchedule ?? this.trimSchedule);
  }
}
