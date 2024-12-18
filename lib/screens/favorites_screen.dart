import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favoriteCities = [];
  Map<String, dynamic> weatherData = {};

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() async {
    final service = FavoriteService();
    final cities = await service.getFavorites();
    setState(() {
      favoriteCities = cities;
    });
    loadWeatherForAllCities();
  }

  void loadWeatherForAllCities() async {
    final futures = favoriteCities.map((city) async {
      try {
        final data = await ApiService().fetchWeatherByCity(city);
        setState(() {
          weatherData[city] = data;
        });
      } catch (e) {
        setState(() {
          weatherData[city] = {'error': 'Fehler: Keine Verbindung oder ungültige Stadt.'};
        });
      }
    }).toList();

    await Future.wait(futures); // Warte auf alle Anfragen
  }

  void addFavorite(String city) async {
    if (favoriteCities.contains(city)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stadt ist bereits in den Favoriten!")),
      );
      return;
    }
    final service = FavoriteService();
    await service.addFavorite(city);
    setState(() {
      favoriteCities.add(city);
      fetchWeatherForCity(city);
    });
  }

  void fetchWeatherForCity(String city) async {
    try {
      final data = await ApiService().fetchWeatherByCity(city);
      setState(() {
        weatherData[city] = data;
      });
    } catch (e) {
      setState(() {
        weatherData[city] = {'error': 'Fehler: Keine Verbindung oder ungültige Stadt.'};
      });
    }
  }

  void removeFavorite(String city) async {
    final service = FavoriteService();
    await service.removeFavorite(city);
    setState(() {
      favoriteCities.remove(city);
      weatherData.remove(city);
    });
  }

  void showAddFavoriteDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Neue Stadt hinzufügen"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Stadtname"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Abbrechen"),
            ),
            TextButton(
              onPressed: () {
                final city = controller.text.trim();
                if (city.isNotEmpty) {
                  addFavorite(city);
                }
                Navigator.pop(context);
              },
              child: const Text("Hinzufügen"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoriten"),
      ),
      body: favoriteCities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: favoriteCities.length,
        itemBuilder: (context, index) {
          final city = favoriteCities[index];
          final cityWeather = weatherData[city];
          return ListTile(
            title: Text(city),
            subtitle: cityWeather != null
                ? (cityWeather['error'] != null
                ? Text(cityWeather['error'])
                : Text(
                "${cityWeather['temperature']}°C - ${cityWeather['description']}"))
                : const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text("Wird geladen..."),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                removeFavorite(city);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddFavoriteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}


