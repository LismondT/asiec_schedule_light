
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/bloc/schedule/remote/remote_schedule_bloc.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/bloc/schedule/remote/remote_schedule_events.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_settings.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_settings_fields_use_case.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/save_settings.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/bloc/settings_event.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/bloc/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettingsUseCase getSettings;
  final SaveSettingsUseCase saveSettings;
  final GetSettingsFieldsUseCase getFields;

  final RemoteScheduleBloc _scheduleBloc;

  late Map<ScheduleRequestType, Map<String, String>> _fields;
  late Map<String, String> _currentFields;
  late SettingsEntity _settings;

  Map<String, String> get currentRequestIds => _currentFields;

  SettingsBloc(this.getSettings, this.saveSettings, this.getFields, this._scheduleBloc) : super(SettingsInitialState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateSettingsEvent>(_onUpdateSettings);
    on<ChangeRequestTypeEvent>(_onChangeRequestType);
    on<SelectRequestIdEvent>(_onSelectRequestId);
  }

  void _onLoadSettings(LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    emit(SettingsLoadingState());

    try {
      _settings = await getSettings();
      _currentFields = {};
      emit(SettingsLoadedState(_settings, {}));
      _fields = await getFields();
      _currentFields = _fields[_settings.requestType] ?? {};
      emit(SettingsLoadedState(_settings, _currentFields));
    }
    catch (e) {
      emit(SettingsErrorState(e.toString()));
    }
  }

  void _onUpdateSettings(UpdateSettingsEvent event, Emitter<SettingsState> emit) async {
    emit(SettingsLoadingState());

    try {
      await saveSettings(params: event.settings);
      _settings = await getSettings();
      emit(SettingsLoadedState(_settings, _currentFields));
    } catch (e) {
      emit(SettingsErrorState(e.toString()));
    }
  }

  void _onChangeRequestType(ChangeRequestTypeEvent event, Emitter<SettingsState> emit) async {
    ScheduleRequestType? type = event.requestType;

    if (type == null) {
      return;
    }
    
    _currentFields = _fields[type]!;
    
    _settings = SettingsEntity(
      isDarkMode: _settings.isDarkMode,
      shemeColor: _settings.shemeColor,
      requestType: type, 
      requestId: '' //Обнуляем id
    );

    saveSettings(params: _settings);

    _scheduleBloc.add(RequestDataSchangedEvent(
      requestType: _settings.requestType,
      requestId: _settings.requestId
    ));

    emit(SettingsLoadedState(_settings, _currentFields));
  }

  void _onSelectRequestId(SelectRequestIdEvent event, Emitter<SettingsState> emit)
  {
    if (event.requestId == null) {
      return;
    }

    _settings = SettingsEntity(
      isDarkMode: _settings.isDarkMode,
      shemeColor: _settings.shemeColor,
      requestType: _settings.requestType, 
      requestId: _currentFields[event.requestId] ?? ''
    );

    saveSettings(params: _settings);

    _scheduleBloc.add(RequestDataSchangedEvent(
      requestType: _settings.requestType,
      requestId: _settings.requestId
    ));

    GetIt.instance<RemoteScheduleBloc>().clearItems();

    emit(SettingsLoadedState(_settings, _currentFields));
  }
}
