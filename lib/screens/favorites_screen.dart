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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() async {
    final service = FavoriteService();
    try {
      final cities = await service.getFavorites();
      setState(() {
        favoriteCities = cities;
        isLoading = false;
      });
      loadWeatherForAllCities();
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fehler beim Laden der Favoriten.")),
        );
      });
    }
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
    try {
      await service.addFavorite(city);
      setState(() {
        favoriteCities.add(city);
        fetchWeatherForCity(city);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$city wurde zu den Favoriten hinzugefügt.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fehler beim Hinzufügen der Stadt.")),
      );
    }
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
    try {
      await service.removeFavorite(city);
      setState(() {
        favoriteCities.remove(city);
        weatherData.remove(city);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$city wurde aus den Favoriten entfernt.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fehler beim Entfernen der Stadt.")),
      );
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteCities.isEmpty
          ? const Center(
        child: Text(
          "Keine Favoriten gefunden.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: favoriteCities.length,
        itemBuilder: (context, index) {
          final city = favoriteCities[index];
          final cityWeather = weatherData[city];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
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



