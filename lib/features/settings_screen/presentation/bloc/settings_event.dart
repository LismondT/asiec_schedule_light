import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';

class SettingsEvent {
  const SettingsEvent();
}

class LoadSettingsEvent extends SettingsEvent {}

class UpdateSettingsEvent extends SettingsEvent {
  final SettingsEntity settings;

  const UpdateSettingsEvent(this.settings);
}

class ChangeRequestTypeEvent extends SettingsEvent {
  final ScheduleRequestType? requestType;

  const ChangeRequestTypeEvent(this.requestType);
}

class SelectRequestIdEvent extends SettingsEvent {
  final String? requestId;

  const SelectRequestIdEvent(this.requestId);
}