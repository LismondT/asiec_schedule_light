import 'package:asiec_schedule/core/bloc/theme/theme_cubit.dart';
import 'package:asiec_schedule/core/bloc/theme/theme_state.dart';
import 'package:asiec_schedule/core/routes/app_route.dart';
import 'package:asiec_schedule/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocProvider<ThemeCubit>(
      create: (context) => sl(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Asiec Schedule Light',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: state.isDark ? Brightness.dark : Brightness.light
              ),
              useMaterial3: true,
            ),
            routerConfig: AppRouter.router,       
          );
        } 
      ),
    );
  }
}
