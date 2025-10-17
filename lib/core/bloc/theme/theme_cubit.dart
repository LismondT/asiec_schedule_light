import 'dart:developer';

import 'package:asiec_schedule/core/bloc/theme/theme_state.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SettingsRepository repository;

  ThemeCubit(this.repository) : super(const ThemeState(Brightness.light)) {
    _checkSelectedTheme();
  }

  Future<void> setThemeBrightness(Brightness brightness) async {
    try {
      emit(ThemeState(brightness));

      SettingsEntity prevSettings = await repository.getSettings();

      await repository.saveSettings(SettingsEntity(
          isDarkMode: brightness == Brightness.dark,
          requestType: prevSettings.requestType,
          requestId: prevSettings.requestId,
          startSavedScheduleByToday: prevSettings.startSavedScheduleByToday));
    } catch (e) {
      log(e.toString());
    }
  }

  void _checkSelectedTheme() async {
    try {
      final settings = await repository.getSettings();
      final brightness =
          settings.isDarkMode ? Brightness.dark : Brightness.light;
      emit(ThemeState(brightness));
    } catch (e) {
      log(e.toString());
    }
  }
}
