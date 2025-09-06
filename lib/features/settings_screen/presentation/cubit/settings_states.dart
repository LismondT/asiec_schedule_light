import 'package:asiec_schedule/features/settings_screen/domain/entities/setting_ids_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';

sealed class SettingsState {}

class SettingsStateInit extends SettingsState {}

class SettingsStateLoading extends SettingsState {}

class SettingsStateLoaded extends SettingsState {
  final SettingsEntity settings;
  final SettingIdsEntity ids;

  SettingsStateLoaded(this.settings, this.ids);
}
