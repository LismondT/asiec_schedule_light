import 'package:asiec_schedule/core/bloc/theme/theme_cubit.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/core/presentation/widgets/app_bar_title.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/setting_ids_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/cubit/settings_cubit.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/cubit/settings_states.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/pages/request_id_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBar
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: AppBarTitle(title: 'Настройки')),

      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => switch (state) {
          SettingsStateInit() => _buildLoading(),
          SettingsStateLoading() => _buildLoading(),
          SettingsStateLoaded(:final ids, :final settings) =>
            _buildLoadedState(context, settings, ids),
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoadedState(
      BuildContext context, SettingsEntity settings, SettingIdsEntity ids) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildThemeSwitch(context),
          _buildRequestTypePicker(context, settings),
          _buildRequestIdPicker(context, settings, ids),
        ],
      ),
    );
  }

  void _setThemeBrightness(BuildContext context, bool value) {
    final brightness = value ? Brightness.dark : Brightness.light;
    context.read<ThemeCubit>().setThemeBrightness(brightness);
  }

  Widget _buildThemeSwitch(BuildContext context) {
    final bool isDarkTheme = context.watch<ThemeCubit>().state.isDark;
    return SwitchListTile(
        title: const Text('Тёмная тема'),
        value: isDarkTheme,
        onChanged: (value) => _setThemeBrightness(context, value));
  }

  Widget _buildRequestTypePicker(
      BuildContext context, SettingsEntity settings) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: const Text('Расписание ',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0)),
          ),
          DropdownButton<ScheduleRequestType>(
            items: [
              DropdownMenuItem(
                  value: ScheduleRequestType.groups,
                  child: const Text('по группе')),
              DropdownMenuItem(
                  value: ScheduleRequestType.teachers,
                  child: const Text('по преподавателю')),
              DropdownMenuItem(
                  value: ScheduleRequestType.classrooms,
                  child: const Text('по аудитории')),
            ],
            onChanged: (value) =>
                context.read<SettingsCubit>().changeRequestType(value!),
            value: settings.requestType,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestIdPicker(
      BuildContext context, SettingsEntity settings, SettingIdsEntity ids) {
    final requestType = settings.requestType;
    final currentIds = ids.getIds(requestType);
    String idKey = '';
    String buttonText;

    for (final entry in currentIds.entries) {
      if (entry.value == settings.requestId) {
        idKey = entry.key;
      }
    }

    //Если id не выбран
    if (idKey == '') {
      switch (settings.requestType) {
        case ScheduleRequestType.groups:
          buttonText = 'Выбрать группу';
          break;
        case ScheduleRequestType.teachers:
          buttonText = 'Выбрать преподавателя';
          break;
        case ScheduleRequestType.classrooms:
          buttonText = 'Выбрать аудиторию';
          break;
      }
    } else {
      switch (settings.requestType) {
        case ScheduleRequestType.groups:
          buttonText = 'Группа: $idKey (изменить)';
          break;
        case ScheduleRequestType.teachers:
          buttonText = 'Преподаватель: $idKey (изменить)';
          break;
        case ScheduleRequestType.classrooms:
          buttonText = 'Аудитория: $idKey (изменить)';
          break;
      }
    }

    return TextButton(
        style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                side:
                    BorderSide(color: Theme.of(context).colorScheme.primary))),
        onPressed: () {
          _showRequestIdDialog(context, currentIds);
        },
        child: Text(buttonText,
            maxLines: 1, style: TextStyle(overflow: TextOverflow.ellipsis)));
  }

  void _showRequestIdDialog(BuildContext context, Map<String, String> ids) {
    showDialog(
        context: context, builder: (context) => RequestIdDialog(ids: ids));
  }
}
