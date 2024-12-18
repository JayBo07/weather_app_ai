import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String apiKey = dotenv.env['API_KEY'] ?? '';

  ApiService() {
    if (apiKey.isEmpty) {
      throw Exception('API-Schlüssel nicht gefunden. Bitte überprüfe deine Konfiguration.');
    }
  }

  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    if (city.trim().isEmpty) {
      throw Exception('Stadtname darf nicht leer sein.');
    }

    final url = Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=metric');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'temperature': data['main']['temp'],
          'description': data['weather'][0]['description'],
          'icon': data['weather'][0]['icon'],
          'minTemp': data['main']['temp_min'],
          'maxTemp': data['main']['temp_max'],
        };
      } else if (response.statusCode == 404) {
        throw Exception('Stadt nicht gefunden. Bitte überprüfe den Namen.');
      } else {
        throw Exception('Unerwarteter API-Fehler: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Netzwerkfehler: Bitte überprüfe deine Verbindung.');
    }
  }

  Future<List<Map<String, dynamic>>> fetch7DayForecast(String city) async {
    if (city.trim().isEmpty) {
      throw Exception('Stadtname darf nicht leer sein.');
    }

    final url = Uri.parse('$baseUrl/forecast?q=$city&appid=$apiKey&units=metric');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List forecast = data['list'];
        return forecast.map((item) {
          return {
            'day': item['dt_txt'],
            'minTemp': item['main']['temp_min'],
            'maxTemp': item['main']['temp_max'],
            'icon': item['weather'][0]['icon'],
          };
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Stadt nicht gefunden. Bitte überprüfe den Namen.');
      } else {
        throw Exception('Unerwarteter API-Fehler: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Netzwerkfehler: Bitte überprüfe deine Verbindung.');
    }
  }
}




