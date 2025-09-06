import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_local_setting_ids.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_setting_ids.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_settings.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/save_local_settings_ids.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/save_settings.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/cubit/settings_states.dart';
import 'package:bloc/bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetSettings _getSettings;
  final GetSettingIds _getIds;
  final GetLocalSettingIds _getLocalIds;
  final SaveSettings _saveSettings;
  final SaveLocalSettingIds _saveLocalIds;

  SettingsCubit(this._getSettings, this._saveSettings, this._getIds,
      this._getLocalIds, this._saveLocalIds)
      : super(SettingsStateInit());

  Future<void> loadSettings() async {
    emit(SettingsStateLoading());

    try {
      final settings = await _getSettings();
      final localIds = await _getLocalIds();
      emit(SettingsStateLoaded(settings, localIds));

      final ids = await _getIds();
      await _saveLocalIds(ids);
      emit(SettingsStateLoaded(settings, ids));
    } catch (e) {
      //ToDo: Error handling
    }
  }

  Future<void> saveSettings(SettingsEntity settings) async {
    try {
      await _saveSettings(settings);
      final updated_settings = await _getSettings();
      final ids = await _getLocalIds();
      emit(SettingsStateLoaded(updated_settings, ids));
    } catch (e) {
      //ToDo: Error handling
    }
  }

  Future<void> changeRequestType(ScheduleRequestType type) async {
    final settings = await _getSettings();

    if (settings.requestType == type) {
      return;
    }

    final updatedSettings = SettingsEntity(
        isDarkMode: settings.isDarkMode, requestType: type, requestId: '');
    await saveSettings(updatedSettings);
  }

  Future<void> changeRequestId(String id) async {
    final settings = await _getSettings();
    final updatedSettings = SettingsEntity(
        isDarkMode: settings.isDarkMode,
        requestType: settings.requestType,
        requestId: id);
    await saveSettings(updatedSettings);
  }
}
