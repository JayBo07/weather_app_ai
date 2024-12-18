import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import '../widgets/weather_chart.dart';

class ForecastScreen extends StatefulWidget {
  final String city;

  const ForecastScreen({required this.city});

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final ApiService apiService = ApiService();
  List<dynamic>? forecastData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchForecastData();
  }

  void fetchForecastData() async {
    try {
      final data = await apiService.fetchForecast(widget.city);
      setState(() {
        forecastData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Fehler beim Laden der Vorhersage.";
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("7-Tage Vorhersage für ${widget.city}"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : _buildForecastContent(),
    );
  }

  Widget _buildForecastContent() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Temperaturverlauf",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Expanded(
            flex: 2,
            child: WeatherChart(forecastData: forecastData!),
          ),
          SizedBox(height: 20),
          Expanded(
            flex: 3,
            child: ListView.separated(
              itemCount: forecastData!.length ~/ 8,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final item = forecastData![index * 8];
                return _buildForecastTile(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastTile(dynamic item) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Image.asset(
          getWeatherIcon(item['weather'][0]['main']),
          width: 40,
          height: 40,
        ),
        title: Text(
          "${item['dt_txt'].split(' ')[0]}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${item['main']['temp']}°C - ${item['weather'][0]['description']}",
          style: TextStyle(fontSize: 16),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.blueAccent),
      ),
    );
  }
}


