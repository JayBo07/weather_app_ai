import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/weather_model.dart';

class ApiService {
  final String _apiKey = dotenv.env['API_KEY']!;
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel> fetchWeatherByCity(String cityOrCoordinates) async {
    final Uri url;

    if (cityOrCoordinates.contains(',')) {
      // Wenn es sich um Koordinaten handelt (z. B. "47.376885,8.5416933")
      final parts = cityOrCoordinates.split(',');
      final latitude = parts[0];
      final longitude = parts[1];
      url = Uri.parse('$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric');
    } else {
      // Wenn es sich um einen Städtenamen handelt
      url = Uri.parse('$_baseUrl/weather?q=$cityOrCoordinates&appid=$_apiKey&units=metric');
    }

    print('Requesting weather data from: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API response: $data');
        await _saveToCache('weather_$cityOrCoordinates.json', {
          'timestamp': DateTime.now().toIso8601String(),
          'data': data,
        });
        return WeatherModel.fromJson(data);
      } else {
        print('HTTP Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      final cachedData = await _loadFromCache('weather_$cityOrCoordinates.json');
      if (cachedData != null) {
        print('Using cached data: $cachedData');
        if (_isCacheValid(cachedData['timestamp'])) {
          return WeatherModel.fromJson(cachedData['data']);
        } else {
          throw Exception('Cache is outdated');
        }
      }
      throw Exception('Error fetching weather data: $e');
    }
  }

  Future<List<WeatherModel>> fetch7DayForecast(String city) async {
    final url = Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric');
    print('Requesting forecast data from: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API response: $data');
        final List<dynamic> forecastList = data['list'];
        await _saveToCache('forecast_$city.json', {
          'timestamp': DateTime.now().toIso8601String(),
          'data': data,
        });
        return forecastList.map((day) => WeatherModel.fromJson(day)).toList();
      } else {
        print('HTTP Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch forecast data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      final cachedData = await _loadFromCache('forecast_$city.json');
      if (cachedData != null) {
        print('Using cached data: $cachedData');
        if (_isCacheValid(cachedData['timestamp'])) {
          final List<dynamic> forecastList = cachedData['data']['list'];
          return forecastList.map((day) => WeatherModel.fromJson(day)).toList();
        } else {
          throw Exception('Cache is outdated');
        }
      }
      throw Exception('Error fetching forecast data: $e');
    }
  }

  Future<void> _saveToCache(String fileName, dynamic data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(json.encode(data));
    } catch (e) {
      // Log cache save errors silently
    }
  }

  Future<Map<String, dynamic>?> _loadFromCache(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      if (await file.exists()) {
        final data = await file.readAsString();
        return json.decode(data) as Map<String, dynamic>;
      }
    } catch (e) {
      // Log cache load errors silently
    }
    return null;
  }

  bool _isCacheValid(String timestamp) {
    final cacheTime = DateTime.parse(timestamp);
    return DateTime.now().difference(cacheTime).inHours <= 1;
  }
}


