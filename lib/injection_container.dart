// ignore_for_file: dead_code

import 'dart:io';

import 'package:asiec_schedule/core/bloc/theme/theme_cubit.dart';
import 'package:asiec_schedule/core/network/http_override.dart';
import 'package:asiec_schedule/core/utils/altag/altag_schedule_time_service.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/repository/schedule_repository.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/use_cases/get_default_schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit.dart';
import 'package:asiec_schedule/features/settings_screen/data/data_sources/remote/altag_ids_api.dart';
import 'package:asiec_schedule/features/settings_screen/data/repositories/altag_settings_fields_repository_impl.dart';
import 'package:asiec_schedule/features/settings_screen/data/repositories/settings_repository_impl.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_fields_repository.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_repository.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_settings.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/get_settings_fields_use_case.dart';
import 'package:asiec_schedule/features/settings_screen/domain/use_cases/save_settings.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/bloc/settings_bloc.dart';
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
import 'features/settings_screen/data/data_sources/remote/asiec_ids_api.dart';
import 'features/settings_screen/data/repositories/asiec_settings_fields_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  const bool isAltag = false;

  final dio = Dio();

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

  SharedPreferencesAsync prefs =
      SharedPreferencesAsync(options: SharedPreferencesOptions());

  //Dependencies
  if (isAltag) {
    //Apis
    sl.registerSingleton<AltagScheduleTimeService>(
        AltagScheduleTimeService(sl()));
    sl.registerSingleton<ScheduleRemoteDatasource>(
        AltagScheduleRemoteDatasource(sl(), sl()));
    sl.registerSingleton<AltagIdsApi>(AltagIdsApi(sl()));

    sl.registerSingleton<SettingsFieldsRepository>(
        AltagSettingsFieldsRepositoryImpl(sl()));
  } else {
    //Apis
    sl.registerSingleton<ScheduleRemoteDatasource>(
        AsiecScheduleRemoteDatasource(sl()));
    sl.registerSingleton<AsiecIdsApi>(AsiecIdsApi(sl()));

    sl.registerSingleton<SettingsFieldsRepository>(
        AsiecSettingsFieldsRepositoryImpl(sl()));
  }

  //Repositories
  sl.registerSingleton<ScheduleRepository>(ScheduleRepositoryImpl(sl()));
  sl.registerSingleton<SettingsRepository>(SettingsRepositoryImpl(prefs));

  //UseCases
  //--Schedule
  sl.registerSingleton<GetDefaultSchedule>(
      GetDefaultSchedule(sl()));

  //--Settings
  sl.registerSingleton<GetSettingsUseCase>(GetSettingsUseCase(sl()));
  sl.registerSingleton<SaveSettingsUseCase>(SaveSettingsUseCase(sl()));
  sl.registerSingleton<GetSettingsFieldsUseCase>(
      GetSettingsFieldsUseCase(sl()));

  //Blocs
  sl.registerFactory<ScheduleCubit>(() => ScheduleCubit(sl(), sl()));
  sl.registerFactory<SettingsBloc>(() => SettingsBloc(sl(), sl(), sl()));
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl()));
}
