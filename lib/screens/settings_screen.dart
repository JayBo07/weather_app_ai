import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isFahrenheit = false;
  bool isDarkMode = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFahrenheit = prefs.getBool('isFahrenheit') ?? false;
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      isLoading = false;
    });
  }

  void savePreferences(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Einstellungen gespeichert")),
    );
  }

  void toggleTheme(bool value) {
    savePreferences('isDarkMode', value);
    final themeNotifier = context.read<ThemeNotifier>();
    themeNotifier.setTheme(value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Einstellungen")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Einstellungen"),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Temperatur in Fahrenheit'),
            value: isFahrenheit,
            onChanged: (value) {
              setState(() {
                isFahrenheit = value;
                savePreferences('isFahrenheit', value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Dunkles Theme'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
                toggleTheme(value);
              });
            },
          ),
          ListTile(
            title: const Text('Standardort festlegen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigiere zur Stadtwahl-Logik
            },
          ),
        ],
      ),
    );
  }
}

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }
}

class PreferencesHelper {
  static Future<bool> getBool(String key, bool defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
}



