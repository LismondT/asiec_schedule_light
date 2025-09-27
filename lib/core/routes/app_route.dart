import 'package:asiec_schedule/core/presentation/pages/root_screen.dart';
import 'package:asiec_schedule/core/utils/constants/route_constants.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/pages/schedule_screen.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/timer_screen/presentation/pages/lecture_timer_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey(debugLabel: 'root');

  static final GoRouter _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: scheduleRoutePath,
      routes: [
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                RootScreen(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                  path: scheduleRoutePath,
                  builder: (context, state) => const ScheduleScreen(),
                )
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: timerRoutePath,
                  builder: (context, state) => const LectureTimerScreen(),
                )
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: settingsRoutePath,
                  builder: (context, state) => const SettingsScreen(),
                )
              ])
            ])
      ]);

  static GoRouter get router => _router;
}
