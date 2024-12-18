import 'package:flutter/material.dart';
import 'dart:async';
import 'package:weather_app/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  final String title;
  final IconData icon;

  const SplashScreen({
    super.key,
    this.title = "Wetter App",
    this.icon = Icons.cloud,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      // Simuliere Initialisierungen wie das Laden von Einstellungen
      await Future.delayed(const Duration(seconds: 3));
      navigateToHome();
    } catch (e) {
      // Fehlerbehandlung (z.B. Loggen oder Fehlermeldung anzeigen)
      print("Fehler während der Initialisierung: $e");
    }
  }

  void navigateToHome() {
    if (Navigator.canPop(context)) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()), // Ersetze durch deinen HomeScreen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: navigateToHome, // Ermöglicht das Überspringen des Splash-Bildschirms
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 100),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Tippen zum Überspringen",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

