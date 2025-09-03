
import 'package:flutter/material.dart';

class ThemeState {
  final Brightness brightness;

  const ThemeState(this.brightness);

  bool get isDark => brightness == Brightness.dark; 
}