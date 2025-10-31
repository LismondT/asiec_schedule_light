import 'package:flutter/material.dart';

class ThemeState {
  final Brightness brightness;
  final Color seedColor;

  const ThemeState(this.brightness, {this.seedColor = Colors.deepPurple});

  bool get isDark => brightness == Brightness.dark;

  ThemeState copyWith({
    Brightness? brightness,
    Color? seedColor,
  }) {
    return ThemeState(
      brightness ?? this.brightness,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}
