import 'package:flutter/services.dart';

/// Klasse mit konstanten Asset-Pfaden
class AssetPaths {
  static const String cloudy = 'assets/images/cloudy.png';
  static const String rainy = 'assets/images/rainy.png';
  static const String snowy = 'assets/images/snowy.png';
  static const String sunny = 'assets/images/sunny.png';
  static const String foggy = 'assets/images/foggy.png';
  static const String thunderstorm = 'assets/images/thunderstorm.png';
  static const String drizzle = 'assets/images/drizzle.png';
  static const String defaultWeather = 'assets/images/default_weather.png';
  static const String defaultIconPath = 'assets/images/default_icon.png';
}

/// Überprüft, ob ein Asset existiert
Future<bool> doesAssetExist(String path) async {
  try {
    await rootBundle.load(path);
    return true;
  } catch (_) {
    return false;
  }
}

/// Gemeinsame Logik für die Zuordnung von Wetterbedingungen zu Asset-Pfaden
Future<String> _getAssetPath(
    String? key, Map<String, String> assetMap, String defaultPath) async {
  if (key == null || key.isEmpty) return defaultPath;

  final path = assetMap[key.toLowerCase()] ?? defaultPath;
  return await doesAssetExist(path) ? path : defaultPath;
}

/// Hintergrundbild basierend auf der Beschreibung abrufen
Future<String> getBackgroundImage(String? description) async {
  const Map<String, String> assetMap = {
    "cloud": AssetPaths.cloudy,
    "rain": AssetPaths.rainy,
    "snow": AssetPaths.snowy,
    "clear": AssetPaths.sunny,
    "mist": AssetPaths.foggy,
    "fog": AssetPaths.foggy,
  };
  return _getAssetPath(description, assetMap, AssetPaths.defaultWeather);
}

/// Wetter-Icon basierend auf der Hauptbeschreibung abrufen
Future<String> getWeatherIcon(String? main) async {
  const Map<String, String> assetMap = {
    "clouds": AssetPaths.cloudy,
    "rain": AssetPaths.rainy,
    "snow": AssetPaths.snowy,
    "clear": AssetPaths.sunny,
    "mist": AssetPaths.foggy,
    "fog": AssetPaths.foggy,
    "thunderstorm": AssetPaths.thunderstorm,
    "drizzle": AssetPaths.drizzle,
  };
  return _getAssetPath(main, assetMap, AssetPaths.defaultIconPath);
}



