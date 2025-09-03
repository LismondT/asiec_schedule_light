import 'package:asiec_schedule/core/presentation/pages/root_screen.dart';
import 'package:asiec_schedule/core/utils/constants/route_constants.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/bloc/schedule/remote/remote_schedule_bloc.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/bloc/schedule/remote/remote_schedule_events.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/pages/schedule_screen.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/timer_screen/pair_timer_screen.dart';
import '../../injection_container.dart';

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
                  builder: (context, state) => BlocProvider(
                    create: (context) => sl<RemoteScheduleBloc>()
                      ..add(InitializeScheduleEvent()),
                    child: ScheduleScreen(),
                  ),
                )
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: timerRoutePath,
                  builder: (context, state) => PairTimerScreen(
                    schedule: GetIt.instance<RemoteScheduleBloc>()
                            .currentDay
                            ?.lessons ??
                        [],
                  ),
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
