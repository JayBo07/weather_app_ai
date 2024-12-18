import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeatherChart extends StatelessWidget {
  final List<dynamic> forecastData;

  const WeatherChart({required this.forecastData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  int index = value.toInt();
                  if (index >= 0 && index < forecastData.length) {
                    return Text(
                      forecastData[index]['dt_txt'].split(' ')[0],
                      style: TextStyle(fontSize: 10),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text("${value.toInt()}\u00b0C"),
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: forecastData.asMap().entries.map((entry) {
                int index = entry.key;
                double temp = entry.value['main']['temp']?.toDouble() ?? 0;
                return FlSpot(index.toDouble(), temp);
              }).toList(),
              isCurved: true,
              barWidth: 4,
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blueAccent.withOpacity(0.3)],
              ),
              belowBarData: BarAreaData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

