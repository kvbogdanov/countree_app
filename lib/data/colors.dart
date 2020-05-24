import 'package:flutter/material.dart';

const MaterialColor countreeTheme = MaterialColor(_countreeThemePrimaryValue, <int, Color>{
  50: Color(0xFFEDF6E6),
  100: Color(0xFFD1E8C0),
  200: Color(0xFFB2D997),
  300: Color(0xFF93CA6D),
  400: Color(0xFF7CBE4D),
  500: Color(_countreeThemePrimaryValue),
  600: Color(0xFF5DAC29),
  700: Color(0xFF53A323),
  800: Color(0xFF499A1D),
  900: Color(0xFF378B12),
});
const int _countreeThemePrimaryValue = 0xFF65B32E;

const MaterialColor countreeThemeAccent = MaterialColor(_countreeThemeAccentValue, <int, Color>{
  100: Color(0xFFCFFFBE),
  200: Color(_countreeThemeAccentValue),
  400: Color(0xFF85FF58),
  700: Color(0xFF73FF3E),
});
const int _countreeThemeAccentValue = 0xFFAAFF8B;