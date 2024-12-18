import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../widgets/weather_chart.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import '../models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  final FavoriteService favoriteService = FavoriteService();

  WeatherModel? weatherData;
  List<dynamic>? forecastData;
  TextEditingController _cityController = TextEditingController();
  List<String> favoriteCities = [];
  String lastSearchedCity = DefaultValues.defaultCity;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadFavorites();
    fetchWeatherData(lastSearchedCity);
  }

  void loadFavorites() async {
    final favorites = await favoriteService.getFavorites();
    setState(() {
      favoriteCities = favorites..sort();
    });
  }

  void fetchWeatherData(String city) async {
    if (isLoading || city.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final data = await apiService.fetchWeather(city);
      setState(() {
        weatherData = data;
        lastSearchedCity = city;
        isLoading = false;
      });
      fetchForecastData(city);
    } catch (e) {
      setState(() {
        weatherData = null;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler: Keine Daten für '$city' gefunden.")),
      );
    }
  }

  void fetchForecastData(String city) async {
    try {
      final data = await apiService.fetchForecast(city);
      setState(() {
        forecastData = data;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void addToFavorites(String city) async {
    if (!favoriteCities.contains(city)) {
      await favoriteService.addFavorite(city);
      loadFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$city zu Favoriten hinzugefügt!")),
      );
    }
  }

  void removeFromFavorites(String city) async {
    await favoriteService.removeFavorite(city);
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    String backgroundImage = weatherData != null
        ? getBackgroundImage(weatherData!.description)
        : AssetPaths.defaultWeather;

    return Scaffold(
      appBar: AppBar(
        title: Text("Wetter App"),
        centerTitle: true,
        backgroundColor: Color(AppColors.primary),
      ),
      body: PageView(
        children: [
          _buildWeatherContent(backgroundImage),
          _buildFavoritesList(),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(String backgroundImage) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchField(),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : weatherData == null
                ? Center(child: Text("Keine Wetterdaten verfügbar."))
                : _buildWeatherCard(),
            SizedBox(height: 20),
            if (forecastData != null) ...[
              Text(
                "7-Tage Vorhersage",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              WeatherChart(forecastData: forecastData!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              weatherData!.city,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Image.asset(
              getWeatherIcon(weatherData!.description),
              width: 80,
            ),
            Text(
              "${weatherData!.temperature}°C",
              style: TextStyle(fontSize: 32),
            ),
            Text(weatherData!.description),
            ElevatedButton(
              onPressed: () => addToFavorites(weatherData!.city),
              child: Text("Zu Favoriten hinzufügen"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _cityController,
            decoration: InputDecoration(
              hintText: "Stadt eingeben...",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                fetchWeatherData(value.trim());
              }
            },
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            String city = _cityController.text.trim();
            if (city.isNotEmpty) fetchWeatherData(city);
          },
          child: Text("Suchen"),
        ),
      ],
    );
  }

  Widget _buildFavoritesList() {
    return Container(
      color: Colors.blue.shade50,
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Favoriten",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: favoriteCities.length,
              itemBuilder: (context, index) {
                final city = favoriteCities[index];
                return ListTile(
                  title: Text(city),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeFromFavorites(city),
                  ),
                  onTap: () => fetchWeatherData(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
