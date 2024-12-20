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
  String selectedLanguage = 'Deutsch';
  String defaultCity = '';
  bool isLoading = true;

  final List<String> supportedLanguages = ['Deutsch', 'Englisch'];

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
      selectedLanguage = prefs.getString('language') ?? 'Deutsch';
      defaultCity = prefs.getString('defaultCity') ?? '';
      isLoading = false;
    });
  }

  void savePreferences(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Einstellungen gespeichert")),
    );
  }

  void toggleTheme(bool value) {
    savePreferences('isDarkMode', value);
    final themeNotifier = context.read<ThemeNotifier>();
    themeNotifier.setTheme(value ? ThemeMode.dark : ThemeMode.light);
  }

  void showCitySelectionDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Standardort festlegen"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Stadtname"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Abbrechen"),
            ),
            TextButton(
              onPressed: () {
                final city = controller.text.trim();
                if (city.isNotEmpty) {
                  setState(() {
                    defaultCity = city;
                    savePreferences('defaultCity', city);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
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
            title: const Text('Temperatur in Fahrenheit anzeigen'),
            value: isFahrenheit,
            onChanged: (value) {
              setState(() {
                isFahrenheit = value;
                savePreferences('isFahrenheit', value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Dunkles Theme aktivieren'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
                toggleTheme(value);
              });
            },
          ),
          ListTile(
            title: const Text('Sprache auswählen'),
            subtitle: Text(selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return ListView(
                    children: supportedLanguages.map((language) {
                      return ListTile(
                        title: Text(language),
                        onTap: () {
                          setState(() {
                            selectedLanguage = language;
                            savePreferences('language', language);
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Standardort festlegen'),
            subtitle: Text(defaultCity.isEmpty ? "Kein Standardort festgelegt" : defaultCity),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: showCitySelectionDialog,
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

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
}

