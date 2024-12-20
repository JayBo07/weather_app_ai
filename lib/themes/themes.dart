import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Globale Theme-Daten
final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
  ).copyWith(
    secondary: Colors.blueAccent,
    surface: Colors.grey[100]!,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(color: Colors.black),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
  ),
  cardTheme: const CardTheme(
    margin: EdgeInsets.all(8),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
  ).copyWith(
    secondary: Colors.blueAccent,
    surface: Colors.grey[800]!,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
  ),
  cardTheme: const CardTheme(
    margin: EdgeInsets.all(8),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  ),
);

final weatherThemes = {
  'sunny': ThemeData(
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.yellow).copyWith(
      secondary: Colors.orangeAccent,
      surface: Colors.amber[100]!,
      onPrimary: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black,
      elevation: 2,
    ),
  ),
  'rainy': ThemeData(
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(
      secondary: Colors.lightBlueAccent,
      surface: Colors.grey[200]!,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueGrey,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
  ),
  'snowy': ThemeData(
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue).copyWith(
      secondary: Colors.white,
      surface: Colors.blue[50]!,
      onPrimary: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.lightBlue,
      foregroundColor: Colors.black,
      elevation: 2,
    ),
  ),
  'cloudy': ThemeData(
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey).copyWith(
      secondary: Colors.blueGrey,
      surface: Colors.grey[300]!,
      onPrimary: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.black,
      elevation: 2,
    ),
  ),
};

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = lightTheme;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeData get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;

  // Lade gespeichertes Theme aus SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _currentTheme = isDarkMode ? darkTheme : lightTheme;
    notifyListeners();
  }

  // Wechsel zwischen hell und dunkel
  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _currentTheme = _themeMode == ThemeMode.dark ? darkTheme : lightTheme;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Wetterabhängiges Theme setzen
  void setWeatherTheme(String condition) {
    if (weatherThemes.containsKey(condition)) {
      _currentTheme = weatherThemes[condition]!;
    } else {
      _currentTheme = lightTheme; // Fallback
    }
    notifyListeners();
  }
}





