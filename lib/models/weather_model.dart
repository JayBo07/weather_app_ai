String translateDescription(String description, String language) {
  const translations = {
    'clear sky': {'de': 'Klarer Himmel', 'es': 'Cielo despejado'},
    'few clouds': {'de': 'Wenige Wolken', 'es': 'Pocas nubes'},
    'scattered clouds': {'de': 'Aufgelockerte Wolken', 'es': 'Nubes dispersas'},
    'rain': {'de': 'Regen', 'es': 'Lluvia'},
    'thunderstorm': {'de': 'Gewitter', 'es': 'Tormenta'},
    'snow': {'de': 'Schnee', 'es': 'Nieve'},
    'mist': {'de': 'Nebel', 'es': 'Niebla'},
  };

  final translationMap = translations[description.toLowerCase()];
  if (translationMap != null) {
    return translationMap[language] ?? description;
  }

  return description;
}

class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;
  final double windSpeed;
  final int humidity;
  final String icon;
  final int sunrise;
  final int sunset;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.humidity,
    required this.icon,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // Überprüfen, ob 'weather' eine Liste ist und nicht leer
    final weather = json['weather'] is List && json['weather'].isNotEmpty
        ? (json['weather'][0] is Map<String, dynamic>
        ? json['weather'][0] as Map<String, dynamic>
        : {})
        : {}; // Wenn 'weather' leer oder ungültig ist, setze es auf ein leeres Map

    return WeatherModel(
      cityName: json['name']?.toString().isNotEmpty == true ? json['name'] : 'Unbekannter Ort', // Setze auf 'Unbekannter Ort', wenn der Name leer ist
      temperature: (json['main']['temp'] as num?)?.toDouble() ?? -999.0, // Spezieller Fehlerwert -999.0 für fehlende Temperatur
      condition: weather['description'] ?? 'Keine Angaben', // Falls 'description' null ist, setze auf 'Keine Angaben'
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0, // Falls 'speed' null ist, setze auf 0.0
      humidity: json['main']['humidity'] ?? 0, // Falls 'humidity' null ist, setze auf 0
      icon: weather['icon'] ?? '', // Falls 'icon' null ist, setze auf leeren String
      sunrise: json['sys']['sunrise'] ?? 0, // Falls 'sunrise' null ist, setze auf 0
      sunset: json['sys']['sunset'] ?? 0, // Falls 'sunset' null ist, setze auf 0
    );
  }

  String getTranslatedCondition(String language) {
    return translateDescription(condition, language);
  }

  String getWeatherIconUrl() {
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }

  Duration getDaylightDuration() {
    return Duration(seconds: sunset - sunrise);
  }
}






