import 'package:asiec_schedule/core/bloc/theme/theme_cubit.dart';
import 'package:asiec_schedule/core/config/flavor_config.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/core/presentation/widgets/app_bar_title.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/setting_ids_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/cubit/settings_cubit.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/cubit/settings_states.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/pages/request_id_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        title: const AppBarTitle(title: 'Настройки'),
        elevation: 0,
        centerTitle: true,
      ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Внешний вид'),
          _buildThemeCard(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Расписание'),
          _buildRequestTypeCard(context, settings),
          const SizedBox(height: 8),
          _buildRequestIdCard(context, settings, ids),
          const SizedBox(height: 8),
          _buildTrimScheduleCard(context, settings),
          const SizedBox(height: 32),
          _buildSectionHeader('Обратная связь'),
          _buildTelegramCard(context),
          const SizedBox(height: 24),
          _buildAppInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    final bool isDarkTheme = context.watch<ThemeCubit>().state.isDark;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDarkTheme ? Icons.nightlight_round : Icons.wb_sunny,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: const Text('Тёмная тема'),
        subtitle: const Text('Переключение между светлой и тёмной темой'),
        trailing: Switch(
          value: isDarkTheme,
          onChanged: (value) => _setThemeBrightness(context, value),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildRequestTypeCard(BuildContext context, SettingsEntity settings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Тип расписания',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ScheduleRequestType>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: [
                DropdownMenuItem(
                  value: ScheduleRequestType.groups,
                  child: Row(
                    children: [
                      Icon(Icons.group,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('по группе'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ScheduleRequestType.teachers,
                  child: Row(
                    children: [
                      Icon(Icons.person,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('по преподавателю'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ScheduleRequestType.classrooms,
                  child: Row(
                    children: [
                      Icon(Icons.meeting_room,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('по аудитории'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().changeRequestType(value);
                }
              },
              initialValue: settings.requestType,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestIdCard(
      BuildContext context, SettingsEntity settings, SettingIdsEntity ids) {
    final requestType = settings.requestType;
    final currentIds = ids.getIds(requestType);
    String idKey = '';
    String buttonText;
    IconData iconData;

    for (final entry in currentIds.entries) {
      if (entry.value == settings.requestId) {
        idKey = entry.key;
      }
    }

    switch (settings.requestType) {
      case ScheduleRequestType.groups:
        buttonText = idKey.isEmpty ? 'Выбрать группу' : 'Группа: $idKey';
        iconData = Icons.group;
        break;
      case ScheduleRequestType.teachers:
        buttonText =
            idKey.isEmpty ? 'Выбрать преподавателя' : 'Преподаватель: $idKey';
        iconData = Icons.person;
        break;
      case ScheduleRequestType.classrooms:
        buttonText = idKey.isEmpty ? 'Выбрать аудиторию' : 'Аудитория: $idKey';
        iconData = Icons.meeting_room;
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(iconData, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(buttonText),
        subtitle: Text(idKey.isEmpty ? 'Не выбрано' : 'Нажмите для изменения'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showRequestIdDialog(context, currentIds),
      ),
    );
  }

  Widget _buildTrimScheduleCard(BuildContext context, SettingsEntity settings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: const Text('Обрезать расписание'),
        subtitle: const Text('Показывать резервное расписание с текущего дня'),
        trailing: Switch(
          value: settings.startSavedScheduleByToday,
          onChanged: (value) async {
            await context.read<SettingsCubit>().changeTrimSchedule(value);
            context.read<ScheduleCubit>().loadDefaultSchedule();
          },
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTelegramCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.telegram, color: Colors.blue),
        ),
        title: const Text('Обратная связь'),
        subtitle: const Text('Напишите нам в Telegram'),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _launchTelegram(context),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              FlavorConfig.instance.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Версия: ${FlavorConfig.instance.displayVersion}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setThemeBrightness(BuildContext context, bool value) {
    final brightness = value ? Brightness.dark : Brightness.light;
    context.read<ThemeCubit>().setThemeBrightness(brightness);
  }

  void _showRequestIdDialog(BuildContext context, Map<String, String> ids) {
    showDialog(
      context: context,
      builder: (context) => RequestIdDialog(ids: ids),
    );
  }

  Future<void> _launchTelegram(BuildContext context) async {
    // Попробуем открыть через tg:// (для приложения)
    const telegramAppUrl =
        'tg://resolve?domain=LismondT'; // Замените на ваш username

    // Резервная ссылка для веб-версии
    const telegramWebUrl = 'https://t.me/LismondT'; // Замените на ваш username

    try {
      // Сначала пробуем открыть в приложении
      final appUri = Uri.parse(telegramAppUrl);
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      }
      // Если приложения нет, открываем в браузере
      else {
        final webUri = Uri.parse(telegramWebUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось открыть Telegram')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при открытии Telegram')),
      );
    }
  }
}
