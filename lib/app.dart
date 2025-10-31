import 'package:asiec_schedule/core/bloc/theme/theme_cubit.dart';
import 'package:asiec_schedule/core/bloc/theme/theme_state.dart';
import 'package:asiec_schedule/core/routes/app_route.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/cubit/settings_cubit.dart';
import 'package:asiec_schedule/features/timer_screen/presentation/cubit/lecture_timer_cubit.dart';
import 'package:asiec_schedule/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
            create: (BuildContext context) => sl<ThemeCubit>()),
        BlocProvider<SettingsCubit>(
            create: (BuildContext context) =>
                sl<SettingsCubit>()..loadSettings()),
        BlocProvider<ScheduleCubit>(
            create: (BuildContext context) =>
                sl<ScheduleCubit>()..loadDefaultSchedule()),
        BlocProvider<LectureTimerCubit>(
            create: (BuildContext context) =>
                sl<LectureTimerCubit>()..startTimer())
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
        return MaterialApp.router(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: state.seedColor,
                brightness: state.isDark ? Brightness.dark : Brightness.light),
            useMaterial3: true,
          ),
          routerConfig: AppRouter.router,
          locale: Locale('ru', 'RU'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru', 'RU'),
            Locale('en', 'US'),
          ],
        );
      }),
    );
  }
}
