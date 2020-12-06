import 'package:flutter/material.dart';

ThemeData applicationTheme(Color currentColor) {
  ThemeData baseTheme = ThemeData.light();

  final Brightness systemBrightness =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window)
          .platformBrightness;
  if (Brightness.dark == systemBrightness) {
    baseTheme = ThemeData.dark();
  }

  final Color primaryColor = currentColor ?? Colors.blue;
  final Color secondaryColor = Colors.lightBlueAccent;

  return baseTheme.copyWith(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      secondaryHeaderColor: secondaryColor,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          foregroundColor: Colors.black, backgroundColor: secondaryColor));
}
