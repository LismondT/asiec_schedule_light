import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl extends SettingsRepository {
  final SharedPreferencesAsync preferences;

  SettingsRepositoryImpl(this.preferences);

  static const _isDarkThemeSelectedKey = 'dark_theme_selected';
  static const _requestTypeKey = 'request_type';
  static const _requestIdKey = 'request_id';

  @override
  Future<SettingsEntity> getSettings() async {
    try {
      final isDarkTheme = await preferences.getBool(_isDarkThemeSelectedKey);
      final requestType = ScheduleRequestType.values[await preferences.getInt(_requestTypeKey) ?? 0];
      final requestId = await preferences.getString(_requestIdKey);
      
      return SettingsEntity(
        isDarkMode: isDarkTheme ?? false,
        shemeColor: Colors.deepPurple,
        requestType: requestType,
        requestId: requestId ?? ''
      );
    } catch(e) {
      final settings = SettingsEntity(
        isDarkMode: false,
        shemeColor: Colors.deepPurple,
        requestType: ScheduleRequestType.groups,
        requestId: ''
      );

      await saveSettings(settings);
      return settings;
    }

  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    await preferences.setBool(_isDarkThemeSelectedKey, settings.isDarkMode);
    await preferences.setInt(_requestTypeKey, settings.requestType.index);
    await preferences.setString(_requestIdKey, settings.requestId);
  }
}