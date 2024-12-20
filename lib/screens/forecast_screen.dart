import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../models/weather_model.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<WeatherModel> forecastData = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchForecast();
  }

  Future<void> fetchForecast() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final city = "${position.latitude},${position.longitude}";
      final data = await ApiService().fetch7DayForecast(city);

      if (data.isEmpty) {
        setState(() {
          errorMessage = "Keine Vorhersagedaten gefunden.";
          isLoading = false;
        });
        return;
      }

      setState(() {
        forecastData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Fehler beim Abrufen der Vorhersagedaten: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  Widget buildForecastTile(WeatherModel day) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Image.network(
          day.getWeatherIconUrl(),
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.wb_cloudy, color: Colors.blue, size: 40),
        ),
        title: Text(
          day.cityName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Min: ${day.temperature - 3}°C | Max: ${day.temperature + 3}°C",
        ),
        trailing: Text(
          day.condition,
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("7-Tage-Vorhersage")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("7-Tage-Vorhersage")),
        body: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("7-Tage-Vorhersage")),
      body: ListView.builder(
        itemCount: forecastData.length,
        itemBuilder: (context, index) => buildForecastTile(forecastData[index]),
      ),
    );
  }
}






