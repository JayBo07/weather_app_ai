// API
const String BASE_API_URL = "https://api.openweathermap.org/data/2.5/";
const String WEATHER_ICON_URL = "https://openweathermap.org/img/wn/";

// Default Stadt
const String DEFAULT_CITY = "Berlin";

// Farben
const int PRIMARY_COLOR_HEX = 0xFF2196F3; // Blau
const int SECONDARY_COLOR_HEX = 0xFF90CAF9; // Hellblau

// Default Werte
class DefaultValues {
  static const String defaultCity = "Berlin";
}

// Farben für Themes
class AppColors {
  static const int primary = 0xFF2196F3; // Blau
  static const int secondary = 0xFF90CAF9; // Hellblau
}

// Pfade zu Wetter-Assets
class AssetPaths {
  static const String sunny = "assets/sunny.png";
  static const String cloudy = "assets/cloudy.png";
  static const String rainy = "assets/rainy.png";
  static const String snowy = "assets/snowy.png";
  static const String foggy = "assets/foggy.png";
  static const String thunderstorm = "assets/thunderstorm.png";
  static const String drizzle = "assets/drizzle.png";
  static const String defaultWeather = "assets/default_weather.png";
}
