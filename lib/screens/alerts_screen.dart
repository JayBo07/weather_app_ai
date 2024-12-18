import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für bessere Datumsformatierung

class AlertsScreen extends StatefulWidget {
  final List<dynamic> alerts;

  AlertsScreen({required this.alerts});

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
      duration: Duration(milliseconds: 800),
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

  // Hilfsfunktion für Datumsformatierung
  String formatDate(int? timestamp) {
    if (timestamp == null || timestamp == 0) return "Unbekannte Zeit";
    return DateFormat('dd.MM.yyyy HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Wetterwarnungen",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.alerts.isEmpty
            ? Center(
          child: Text(
            "Keine aktuellen Warnungen",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : ListView.builder(
          itemCount: widget.alerts.length,
          itemBuilder: (context, index) {
            final alert = widget.alerts[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Colors.yellow[50], // Hintergrundfarbe
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titelzeile mit Icon
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.redAccent, size: 36),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            alert['title'] ?? "Unbenannte Warnung",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Beschreibung
                    Text(
                      alert['description'] ??
                          "Keine Beschreibung verfügbar",
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    SizedBox(height: 10),

                    // Zeitangaben
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Startzeit: ${formatDate(alert['start'])}",
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[700]),
                        ),
                        Text(
                          "Endzeit: ${formatDate(alert['end'])}",
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
