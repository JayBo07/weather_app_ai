import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';


class WeatherChart extends StatelessWidget {
  final List<WeatherModel> forecastData;

  const WeatherChart({super.key, required this.forecastData});

  @override
  Widget build(BuildContext context) {
    if (forecastData.isEmpty) {
      return const Center(child: Text("Keine Vorhersagedaten verfügbar"));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3, // Dynamische Höhe
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    int index = value.toInt();
                    if (index >= 0 && index < forecastData.length) {
                      return Text(
                        DateFormat.E().format(forecastData[index].timestamp),
                        style: const TextStyle(fontSize: 12),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    return Text(
                      '${value.toInt()}°C',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: forecastData.asMap().entries.map((entry) {
                  int index = entry.key;
                  double temp = entry.value.temperature;
                  return FlSpot(index.toDouble(), temp);
                }).toList(),
                isCurved: true,
                barWidth: 4,
                color: Colors.blue,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

