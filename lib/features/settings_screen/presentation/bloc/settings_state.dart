import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitialState extends SettingsState {}

class SettingsLoadingState extends SettingsState {}

class SettingsLoadedState extends SettingsState {
  final SettingsEntity settings;
  final Map<String, String> fields;

  const SettingsLoadedState(this.settings, this.fields);
}

class SettingsErrorState extends SettingsState {
  final String message;

  const SettingsErrorState(this.message);
}