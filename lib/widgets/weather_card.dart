import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class WeatherCard extends StatelessWidget {
  final String city;
  final double temperature;
  final String description;
  final String weatherCondition;

  const WeatherCard({
    required this.city,
    required this.temperature,
    required this.description,
    required this.weatherCondition,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "$temperature°C",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
            Image.asset(
              getWeatherIcon(weatherCondition),
              width: 60,
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
