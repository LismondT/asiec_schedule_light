
import 'package:flutter/material.dart';

class ThemeState {
  final Brightness brightness;
  final Color color;

  const ThemeState(this.brightness, {this.color = Colors.deepPurple});

  bool get isDark => brightness == Brightness.dark; 
}