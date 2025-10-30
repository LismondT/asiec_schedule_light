import 'dart:convert';

import 'package:asiec_schedule/core/domain/entity/schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/data/data_sources/local/schedule_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleSharedPreferencesDatasource extends ScheduleLocalDatasource {
  static const String _scheduleKey = 'local_schedule';

  final SharedPreferencesAsync _preferences;

  ScheduleSharedPreferencesDatasource(this._preferences);

  @override
  Future<Schedule> getSchedule() async {
    try {
      final json = await _preferences.getString(_scheduleKey) ?? '';
      final Map<String, dynamic> scheduleRaw = jsonDecode(json);
      return Schedule.fromJson(scheduleRaw);
    } catch(e) {
      return Schedule(
          firstDate: DateTime(0),
          lastDate: DateTime(0),
          days: []);
    }
  }

  @override
  Future<void> saveSchedule(Schedule schedule) async {
    final json = jsonEncode(schedule.toJson());
    await _preferences.setString(_scheduleKey, json);
  }
}
