
import 'package:asiec_schedule/core/bloc/theme/theme_cubit.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/core/presentation/widgets/app_bar_title.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/bloc/settings_bloc.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/bloc/settings_event.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/bloc/settings_state.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/pages/request_id_dialog.dart';
import 'package:asiec_schedule/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (context) => sl()..add(LoadSettingsEvent()),
      child: Scaffold(
        //AppBar
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: AppBarTitle(title: 'Настройки') 
        ),
        
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder:(context, state) {
        
            //Loading state
            if (state is SettingsLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
        
            //Loaded State
            if (state is SettingsLoadedState) {
              return _buildLoadedState(context, state.settings);
            }
        
            if (state is SettingsErrorState) {
              return Center(child: Text(state.message));
            }
        
            return const SizedBox();
          },
        ),
      )
    );
  }

  Widget _buildLoadedState(BuildContext context, SettingsEntity settings) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildThemeSwitch(context),
          _buildRequestTypePicker(context, settings),
          _buildRequestIdPicker(context, settings),
        ],
      ),
    );
  }


  void _setThemeBrightness(BuildContext context, bool value) {
    final brightness = value ? Brightness.dark : Brightness.light;
    context.read<ThemeCubit>().setThemeBrightness(brightness);
  }


  Widget _buildThemeSwitch(BuildContext context)
  {
    final bool isDarkTheme = context.watch<ThemeCubit>().state.isDark;
    return SwitchListTile(
      title: const Text('Тёмная тема'),
      value: isDarkTheme,
      onChanged: (value) => _setThemeBrightness(context, value)
    );
  }


  Widget _buildRequestTypePicker(BuildContext context, SettingsEntity settings)
  {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: const Text('Расписание ', style:  TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16.0
            )),
          ),
          DropdownButton<ScheduleRequestType>(
            items: [
              DropdownMenuItem(
                value: ScheduleRequestType.groups,
                child: const Text('по группе')
              ),
              DropdownMenuItem(
                value: ScheduleRequestType.teachers,
                child: const Text('по преподавателю')
              ),
              DropdownMenuItem(
                value: ScheduleRequestType.classrooms,
                child: const Text('по аудитории')
              ),
            ],
            onChanged: (value) => context.read<SettingsBloc>().add(ChangeRequestTypeEvent(value)),
            value: settings.requestType,
          ),
        ],
      ),
    );
  }


  Widget _buildRequestIdPicker(BuildContext context, SettingsEntity settings)
  {
    final ids = BlocProvider.of<SettingsBloc>(context).currentRequestIds;
    String idKey = '';
    String buttonText;

    for (final entry in ids.entries) {
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
    }
    else {
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
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary
          )
        )
      ),
      onPressed: () => _showRequestIdDialog(context),
      child: Text(buttonText,
        maxLines: 1,
        style: TextStyle(
          overflow: TextOverflow.ellipsis
        )
      )
    );
  }


  void _showRequestIdDialog(BuildContext context)
  {
    final bloc = BlocProvider.of<SettingsBloc>(context);

    showDialog(
      context: context,
      builder: (context) => RequestIdDialog(settingsBloc: bloc)
    );
  }
}