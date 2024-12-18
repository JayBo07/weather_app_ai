import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class ApiService {
  final String apiKey = dotenv.env['API_KEY'] ?? '';

  // Allgemeine Methode zum API-Aufruf mit Timeout und Retry
  Future<dynamic> _getApiResponse(String url) async {
    const int retries = 3;
    const Duration timeout = Duration(seconds: 10);

    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(timeout);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          print('Versuch $attempt fehlgeschlagen: ${response.statusCode}');
        }
      } catch (e) {
        print('Fehler beim API-Aufruf (Versuch $attempt): $e');
      }
    }
    throw Exception('API-Aufruf fehlgeschlagen nach $retries Versuchen');
  }

  // Aktuelles Wetter abrufen
  Future<WeatherModel> fetchWeather(String city) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=de";

    final data = await _getApiResponse(url);
    return WeatherModel.fromJson(data);
  }

  // 7-Tage Wettervorhersage abrufen
  Future<List<WeatherModel>> fetchForecast(String city) async {
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=de";

    final data = await _getApiResponse(url);
    return WeatherModel.fromForecastJson(data['list']);
  }
}





