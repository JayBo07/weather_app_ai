import 'package:flutter/material.dart';

/// API-Konfigurationen
class ApiConfig {
  static const String baseApiUrl = "https://api.openweathermap.org/";
  static const String weatherIconUrl = "https://openweathermap.org/img/wn/";

  static void validateApiConfiguration() {
    if (!baseApiUrl.startsWith("https://")) {
      throw Exception("Ungültige baseApiUrl: $baseApiUrl");
    }
    if (!weatherIconUrl.startsWith("https://")) {
      throw Exception("Ungültige weatherIconUrl: $weatherIconUrl");
    }
  }
}

/// Wetterbedingungen als Enum
enum WeatherCondition { sunny, rainy, cloudy, night, defaultCondition }

/// Regionen als Enum
enum Region { DE, US, UK, FR, IT, Default }

/// Farben für Themes
class AppColors {
  static const int primary = 0xFF2196F3; // Blau
  static const int secondary = 0xFF90CAF9; // Hellblau
  static const int rainy = 0xFF607D8B; // Grau
  static const int sunny = 0xFFFFC107; // Gelb
  static const int night = 0xFF3F51B5; // Dunkelblau
  static const int cloudy = 0xFF455A64; // Blau-Grau

  /// Farbe basierend auf Wetterbedingungen und optionaler Helligkeit
  static int getColor(WeatherCondition condition,
      {Brightness brightness = Brightness.light}) {
    final isDark = brightness == Brightness.dark;
    switch (condition) {
      case WeatherCondition.rainy:
        return isDark ? 0xFF37474F : rainy;
      case WeatherCondition.sunny:
        return isDark ? 0xFFFFA000 : sunny;
      case WeatherCondition.cloudy:
        return isDark ? 0xFF263238 : cloudy;
      case WeatherCondition.night:
        return night;
      default:
        return isDark ? 0xFF1E88E5 : primary;
    }
  }
}

/// Standardwerte für die App
class DefaultValues {
  static const String defaultCity = "Berlin";
  static const double defaultTemperature = 20.0;
  static const String defaultIcon = "01d";

  /// Gibt die Standardstadt für eine Region zurück
  static String getDefaultCity(String region) {
    const defaultCities = {
      "DE": "Berlin",
      "US": "New York",
      "UK": "London",
      "FR": "Paris",
      "IT": "Rome",
    };

    return defaultCities[region] ?? "London";
  }
}

/// Dynamische Pfade zu Wetter-Assets
class AssetPaths {
  static const String defaultWeather = "assets/icons/default_weather.png";

  /// Dynamisch generierter Pfad basierend auf Icon-Code
  static String getWeatherAsset(String iconCode) {
    return "assets/icons/$iconCode.png";
  }
}

