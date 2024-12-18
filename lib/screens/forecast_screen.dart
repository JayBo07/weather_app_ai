
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<Map<String, dynamic>> forecastData = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchForecast();
  }

  void fetchForecast() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final city = "${position.latitude},${position.longitude}";
      final data = await ApiService().fetch7DayForecast(city);

      if (data.isEmpty || data.any((day) => day['day'] == null)) {
        setState(() {
          errorMessage = "Ungültige Vorhersagedaten erhalten.";
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

  Widget buildForecastTile(Map<String, dynamic> day) {
    return ListTile(
      leading: Image.asset(
        'assets/icons/${day['icon']}.png',
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.wb_cloudy, color: Colors.blue, size: 40),
      ),
      title: Text(day['day'] ?? "Unbekannter Tag"),
      subtitle: Text('Min: ${day['minTemp']}°C | Max: ${day['maxTemp']}°C'),
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
            style: const TextStyle(color: Colors.red),
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




