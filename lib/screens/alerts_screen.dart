import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für bessere Datumsformatierung

class AlertsScreen extends StatefulWidget {
  final List<dynamic> alerts;

  const AlertsScreen({super.key, required this.alerts});

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialisiere AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Definiere Fade-Animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Starte Animation beim Aufbau der Seite
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void refreshAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  // Hilfsfunktion für Datumsformatierung
  String formatTimestamp(int? timestamp, {String format = 'dd.MM.yyyy HH:mm'}) {
    if (timestamp == null || timestamp == 0) return "Unbekannte Zeit";
    return DateFormat(format).format(
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
    );
  }

  // Farbe basierend auf der Schwere
  Color _getSeverityColor(String severity) {
    const Map<String, Color> severityColors = {
      'hoch': Colors.red,
      'mittel': Colors.orange,
      'niedrig': Colors.yellow,
      'default': Colors.blue,
    };
    return severityColors[severity.toLowerCase()] ?? severityColors['default']!;
  }

  // Icon basierend auf der Schwere
  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'hoch':
        return Icons.warning;
      case 'mittel':
        return Icons.error_outline;
      case 'niedrig':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  List<Widget> _buildAlerts() {
    return widget.alerts.map((alert) {
      if (alert == null || !alert.containsKey('start') || !alert.containsKey('description')) {
        return const ListTile(
          title: Text("Ungültige Warnung"),
          subtitle: Text("Einige Daten fehlen."),
        );
      }

      final severity = alert['severity'] ?? 'Unbekannt';
      final description = alert['description'] ?? 'Keine Beschreibung';

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        color: _getSeverityColor(severity), // Hintergrundfarbe
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titelzeile mit Icon
              Row(
                children: [
                  Icon(_getSeverityIcon(severity),
                      color: Colors.white, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      severity,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Beschreibung
              Text(
                description,
                style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
              ),
              const SizedBox(height: 10),

              // Zeitangaben
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Startzeit: ${formatTimestamp(alert['start'])}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white70),
                  ),
                  Text(
                    "Endzeit: ${formatTimestamp(alert['end'])}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Wetterwarnungen"),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "Keine Warnungen verfügbar.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Wetterwarnungen",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          children: _buildAlerts(),
        ),
      ),
    );
  }
}

