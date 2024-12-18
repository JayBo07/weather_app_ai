import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentLocation = "Aktueller Standort";
  Map<String, dynamic>? currentWeather;
  String backgroundAsset = "assets/default_weather.png";
  String errorMessage = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation();
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Standortberechtigung verweigert.");
    }
  }

  void fetchCurrentLocation() async {
    try {
      await checkLocationPermission();
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      currentLocation = "${position.latitude},${position.longitude}";
      fetchCurrentWeather();
    } catch (e) {
      setState(() {
        errorMessage = "Fehler beim Abrufen des Standorts: Bitte überprüfe deine Berechtigungen.";
        isLoading = false;
      });
    }
  }

  void fetchCurrentWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      final weatherData = await ApiService().fetchWeatherByCity(currentLocation);
      setState(() {
        currentWeather = weatherData;
        backgroundAsset = getBackgroundAsset(weatherData['icon']);
        errorMessage = "";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Ein Fehler ist aufgetreten. Bitte überprüfe deine Internetverbindung.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getBackgroundAsset(String iconCode) {
    switch (iconCode) {
      case '01d':
        return 'assets/sunny.png';
      case '02d':
      case '03d':
        return 'assets/partly_cloudy.png';
      case '04d':
        return 'assets/cloudy.png';
      case '09d':
      case '10d':
        return 'assets/rainy.png';
      case '11d':
        return 'assets/thunderstorm.png';
      case '13d':
        return 'assets/snowy.png';
      case '50d':
        return 'assets/foggy.png';
      default:
        print("Unbekannter Icon-Code: $iconCode");
        return 'assets/default_weather.png';
    }
  }

  Widget buildWeatherInfo() {
    return Column(
      children: [
        Text("${currentWeather!['temperature']}°C",
            style: const TextStyle(fontSize: 40, color: Colors.white)),
        Text("${currentWeather!['description']}",
            style: const TextStyle(fontSize: 20, color: Colors.white)),
      ],
    );
  }

  Widget buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Wetter App")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wetter App"),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundAsset,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Ort eingeben...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isEmpty) {
                      setState(() {
                        errorMessage = "Bitte gib einen gültigen Stadtnamen ein.";
                      });
                      return;
                    }

                    ApiService().fetchWeatherByCity(value).then((weatherData) {
                      setState(() {
                        currentLocation = value;
                        currentWeather = weatherData;
                        backgroundAsset = getBackgroundAsset(weatherData['icon']);
                        errorMessage = "";
                      });
                    }).catchError((e) {
                      setState(() {
                        errorMessage = "Ort nicht gefunden. Bitte erneut versuchen.";
                      });
                    });
                  },
                ),
              ),
              if (errorMessage.isNotEmpty) buildErrorMessage(),
              if (currentWeather != null) buildWeatherInfo(),
            ],
          ),
        ],
      ),
    );
  }
}




