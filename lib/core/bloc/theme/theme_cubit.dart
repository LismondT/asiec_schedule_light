import 'dart:convert';
import 'dart:developer';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:asiec_schedule/core/bloc/theme/theme_state.dart';
import 'package:asiec_schedule/core/config/flavor_config.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'color_options.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SettingsRepository repository;

  ThemeCubit(this.repository) : super(const ThemeState(Brightness.light)) {
    _checkSelectedTheme();
  }

  Future<void> setThemeBrightness(Brightness brightness) async {
    try {
      emit(state.copyWith(brightness: brightness));

      SettingsEntity prevSettings = await repository.getSettings();

      await repository.saveSettings(prevSettings
          .copyWith(isDarkMode: brightness == Brightness.dark)
          .copyWith(themeSeedColor: _colorToJson(state.seedColor)));

      try {
        await AppMetrica.reportEventWithMap('Выбор светлой/темной темы', {
          'flavor': FlavorConfig.instance.flavor.name,
          'theme': brightness.name
        });
      } catch (e) {
        //
      }
    } catch (e) {
      log(e.toString());
    }
  }

  void _checkSelectedTheme() async {
    try {
      final settings = await repository.getSettings();
      final brightness =
          settings.isDarkMode ? Brightness.dark : Brightness.light;
      final seedColor =
          _jsonToColor(settings.themeSeedColor) ?? Colors.deepPurple;

      emit(ThemeState(brightness, seedColor: seedColor));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> setSeedColor(Color color) async {
    try {
      emit(state.copyWith(seedColor: color));

      SettingsEntity prevSettings = await repository.getSettings();

      await repository.saveSettings(
          prevSettings.copyWith(themeSeedColor: _colorToJson(color)));

      try {
        await AppMetrica.reportEventWithMap('Выбор цвета темы', {
          'flavor': FlavorConfig.instance.flavor.name,
          'color': _getColorName(color)
        });
      } catch (e) {
        //
      }
    } catch (e) {
      log(e.toString());
    }
  }

  String _colorToJson(Color color) {
    return jsonEncode({
      'value': color.value,
    });
  }

  // Восстанавливаем Color из JSON-строки
  Color? _jsonToColor(String? colorJson) {
    if (colorJson == null || colorJson.isEmpty) return null;
    try {
      final map = jsonDecode(colorJson);
      return Color(map['value']);
    } catch (e) {
      return null;
    }
  }

  String _getColorName(Color color) {
    for (var option in colorOptions) {
      if ((option['color'] as Color).value == color.value) {
        return option['name'] as String;
      }
    }
    return 'Пользовательский';
  }
}
