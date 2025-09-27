import 'dart:convert';

import 'package:asiec_schedule/features/settings_screen/data/data_sources/local/local_ids_datasource.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/setting_ids_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesIdsDatasource extends LocalIdsDatasource {
  static const String _idsKey = "local_ids";

  final SharedPreferencesAsync _preferences;

  SharedPreferencesIdsDatasource(this._preferences);

  @override
  Future<SettingIdsEntity> loadIds() async {
    try {
      final json = await _preferences.getString(_idsKey) ?? '';
      final Map<String, dynamic> scheduleRaw = jsonDecode(json);
      return SettingIdsEntity.fromJson(scheduleRaw);
    } catch (e) {
      return SettingIdsEntity(groupIds: {}, teacherIds: {}, classroomIds: {});
    }
  }

  @override
  Future<void> saveIds(SettingIdsEntity ids) async {
    final json = jsonEncode(ids.toJson());
    await _preferences.setString(_idsKey, json);
  }
}
