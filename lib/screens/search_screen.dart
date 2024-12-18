import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService apiService = ApiService();
  TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String errorMessage = "";
  String lastSearchedCity = "";

  void searchCity(String city) async {
    if (city == lastSearchedCity || isLoading) return;
    setState(() {
      isLoading = true;
      errorMessage = "";
      searchResults.clear();
    });

    try {
      final data = await apiService.fetchWeather(city);
      setState(() {
        searchResults = [data];
        lastSearchedCity = city;
        _searchController.clear();
      });
    } catch (e) {
      setState(() {
        errorMessage = "Keine Daten für '$city' gefunden.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler: Keine Daten für '$city' gefunden.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stadt suchen"),
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
              SizedBox(height: 20),
              if (isLoading) Center(child: CircularProgressIndicator())
              else if (errorMessage.isNotEmpty)
                Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              else if (searchResults.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) => _buildSearchResultTile(searchResults[index]),
                    ),
                  )
                else
                  Center(
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
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Stadt eingeben...",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) searchCity(value.trim());
            },
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            String city = _searchController.text.trim();
            if (city.isNotEmpty) searchCity(city);
          },
          child: Text("Suchen"),
        ),
      ],
    );
  }

  Widget _buildSearchResultTile(dynamic result) {
    return FadeInWidget(
      child: Card(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(Icons.location_city, color: Colors.blueAccent, size: 30),
          title: Text(
            result['name'] ?? "Unbekannte Stadt",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${result['main']['temp']}\u00b0C - ${result['weather'][0]['description']}",
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onTap: () => Navigator.pop(context, result['name']),
        ),
      ),
    );
  }
}

class FadeInWidget extends StatelessWidget {
  final Widget child;
  const FadeInWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500),
      builder: (context, opacity, _) => Opacity(opacity: opacity, child: child),
    );
  }
}
