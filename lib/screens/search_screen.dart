import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String errorMessage = "";
  Timer? _debounce;

  void searchCity(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        setState(() {
          searchResults = [];
          errorMessage = "Bitte gib einen gültigen Stadtnamen ein.";
        });
        return;
      }

      setState(() {
        isLoading = true;
        errorMessage = "";
      });

      try {
        final data = await apiService.fetchWeatherByCity(query);
        setState(() {
          searchResults = [data];
          errorMessage = "";
        });
      } catch (e) {
        setState(() {
          errorMessage = "Fehler beim Abrufen der Daten: ${e.toString()}";
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stadt suchen"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (errorMessage.isNotEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ],
                  ),
                )
              else if (searchResults.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) => SearchResultTile(result: searchResults[index]),
                    ),
                  )
                else
                  const Center(
                    child: Text(
                      "Keine Ergebnisse gefunden.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Stadt eingeben...",
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: isLoading ? const CircularProgressIndicator(strokeWidth: 2) : null,
      ),
      onChanged: searchCity,
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final dynamic result;
  const SearchResultTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.location_city, color: Colors.blueAccent, size: 30),
        title: Text(
          result['name'] ?? "Unbekannte Stadt",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          result['main']?['temp'] != null && result['weather'] != null
              ? "${result['main']['temp']}°C - ${result['weather'][0]['description'] ?? ''}"
              : "Daten nicht verfügbar",
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () => Navigator.pop(context, result['name']),
      ),
    );
  }
}

class FadeInWidget extends StatelessWidget {
  final Widget child;
  const FadeInWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, opacity, _) => Opacity(opacity: opacity, child: child),
    );
  }
}

