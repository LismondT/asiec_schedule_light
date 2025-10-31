// ignore_for_file: dead_code

import 'dart:developer';
import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:asiec_schedule/core/bloc/theme/theme_cubit.dart';
import 'package:asiec_schedule/core/config/flavor_config.dart';
import 'package:asiec_schedule/core/network/http_override.dart';
import 'package:asiec_schedule/core/utils/altag/altag_schedule_time_service.dart';
import 'package:asiec_schedule/features/schedule_screen/data/data_sources/local/schedule_local_datasource.dart';
import 'package:asiec_schedule/features/schedule_screen/data/data_sources/local/schedule_shared_preferences_datasource.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/repository/schedule_repository.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/get_default_schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/get_local_schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/get_schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/save_local_schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit.dart';
import 'package:asiec_schedule/features/settings_screen/data/data_sources/local/local_ids_datasource.dart';
import 'package:asiec_schedule/features/settings_screen/data/data_sources/local/shared_preferences_ids_datasource.dart';
import 'package:asiec_schedule/features/settings_screen/data/data_sources/remote/altag_ids_datasource.dart';
import 'package:asiec_schedule/features/settings_screen/data/data_sources/remote/remote_ids_datasource.dart';
import 'package:asiec_schedule/features/settings_screen/data/repositories/settings_repository_impl.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_repository.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_local_setting_ids.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_setting_ids.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_settings.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/save_local_settings_ids.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/save_settings.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/cubit/settings_cubit.dart';
import 'package:asiec_schedule/features/timer_screen/domain/use_cases/get_current_day.dart';
import 'package:asiec_schedule/features/timer_screen/presentation/cubit/lecture_timer_cubit.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/schedule_screen/data/data_sources/remote/altag_schedule_remote_datasource.dart';
import 'features/schedule_screen/data/data_sources/remote/asiec_schedule_remote_datasource.dart';
import 'features/schedule_screen/data/data_sources/remote/schedule_remote_datasource.dart';
import 'features/schedule_screen/data/repository/schedule_repository_impl.dart';
import 'features/settings_screen/data/data_sources/remote/asiec_ids_datasource.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await FlavorConfig.instance.initialize();

  _initializeAppMetricaInBackground();

  final dio = Dio(BaseOptions());

  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  sl.registerSingleton<Dio>(dio);
  sl.registerSingleton<Client>(Client());

  HttpOverrides.global = HttpOverride();
  await initializeDateFormatting('ru_RU', null);

  sl.registerSingleton(
      SharedPreferencesAsync(options: SharedPreferencesOptions()));

  //Dependencies
  //--LocalDatasources
  sl.registerSingleton<LocalIdsDatasource>(
      SharedPreferencesIdsDatasource(sl()));
  sl.registerSingleton<ScheduleLocalDatasource>(
      ScheduleSharedPreferencesDatasource(sl()));

  if (FlavorConfig.instance.isAltag) {
    //RemoteDatasources
    final timeService = AltagScheduleTimeService(sl());
    await timeService.initialize();
    sl.registerSingleton<AltagScheduleTimeService>(timeService);
    sl.registerSingleton<ScheduleRemoteDatasource>(
        AltagScheduleRemoteDatasource(sl(), sl()));
    sl.registerSingleton<RemoteIdsDatasource>(AltagIdsDatasource(sl()));
  }

  if (FlavorConfig.instance.isAsiec) {
    //RemoteDatasources
    sl.registerSingleton<ScheduleRemoteDatasource>(
        AsiecScheduleRemoteDatasource(sl()));
    sl.registerSingleton<RemoteIdsDatasource>(AsiecIdsDatasource(sl()));
  }

  //Repositories
  sl.registerSingleton<ScheduleRepository>(ScheduleRepositoryImpl(sl(), sl()));
  sl.registerSingleton<SettingsRepository>(
      SettingsRepositoryImpl(sl(), sl(), sl()));

  //UseCases
  //--Schedule
  sl.registerSingleton<GetDefaultSchedule>(GetDefaultSchedule(sl()));
  sl.registerSingleton(GetSchedule(sl()));
  sl.registerSingleton(GetLocalSchedule(sl()));
  sl.registerSingleton(SaveLocalSchedule(sl()));

  //--Settings
  sl.registerSingleton<GetSettings>(GetSettings(sl()));
  sl.registerSingleton<GetSettingIds>(GetSettingIds(sl()));
  sl.registerSingleton<GetLocalSettingIds>(GetLocalSettingIds(sl()));
  sl.registerSingleton<SaveSettings>(SaveSettings(sl()));
  sl.registerSingleton<SaveLocalSettingIds>(SaveLocalSettingIds(sl()));

  //--Timer
  sl.registerSingleton(GetCurrentDay(sl()));

  //Cubits
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl()));
  sl.registerFactory<ScheduleCubit>(
      () => ScheduleCubit(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory<SettingsCubit>(
      () => SettingsCubit(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory(() => LectureTimerCubit(sl()));
}

void _initializeAppMetricaInBackground() {
  Future.microtask(() async {
    try {
      final config = FlavorConfig.instance;

      await Future.delayed(const Duration(milliseconds: 500));

      await AppMetrica.activate(AppMetricaConfig(
        config.metricaApi,
        appVersion: config.version,
        appBuildNumber: int.parse(config.buildNumber),
        sessionTimeout: 30,
        locationTracking: false,
      ));

      await AppMetrica.reportEventWithMap('app_launch', {
        'flavor': config.flavor.name,
        'app_version': config.displayVersion,
        'build_number': config.buildNumber,
        'platform': 'android',
        'timestamp': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      log('AppMetrica initialization error: $e');
    }
  });
}
