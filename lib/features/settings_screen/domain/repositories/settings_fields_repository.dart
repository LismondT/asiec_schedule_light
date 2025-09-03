import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

abstract class SettingsFieldsRepository {
  Future<Map<ScheduleRequestType, Map<String, String>>> getSettingsFields();
}