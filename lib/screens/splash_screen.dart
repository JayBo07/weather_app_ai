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
  bool showRetryButton = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      setState(() {
        showRetryButton = false;
        errorMessage = "";
      });
      // Simuliere Initialisierungen wie das Laden von Einstellungen
      await Future.delayed(const Duration(seconds: 3));
      navigateToHome();
    } catch (e) {
      // Fehlerbehandlung mit Feedback-Mechanismus
      setState(() {
        showRetryButton = true;
        errorMessage = "Fehler bei der Initialisierung: ${e.toString()}";
      });
    }
  }

  void navigateToHome() {
    if (Navigator.canPop(context)) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: navigateToHome,
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
                if (!showRetryButton)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                else ...[
                  ElevatedButton(
                    onPressed: initializeApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Erneut versuchen"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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


