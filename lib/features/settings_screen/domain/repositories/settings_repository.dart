
import 'package:asiec_schedule/features/settings_screen/domain/entities/setting_ids_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<void> saveSettings(SettingsEntity settings);
  Future<SettingIdsEntity> getIds();
  Future<SettingIdsEntity> getIdsLocal();
  Future<void> saveIds(SettingIdsEntity ids);
}