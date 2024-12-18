class WeatherModel {
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final String city;

  WeatherModel({
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.city,
  });

  // JSON-Daten in WeatherModel umwandeln
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['main']['temp']?.toDouble() ?? 0.0,
      description: json['weather'][0]['description'] ?? 'Keine Beschreibung',
      humidity: json['main']['humidity']?.toInt() ?? 0,
      windSpeed: json['wind']['speed']?.toDouble() ?? 0.0,
      city: json['name'] ?? 'Unbekannte Stadt',
    );
  }

  // Wettervorhersage-Liste deserialisieren
  static List<WeatherModel> fromForecastJson(List<dynamic> list) {
    return list.map((item) => WeatherModel.fromJson(item)).toList();
  }
}

