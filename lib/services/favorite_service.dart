import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoritesKey = 'favoriteCities';
  SharedPreferences? _prefs;

  // SharedPreferences Instanz laden
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Favoriten abrufen
  Future<List<String>> getFavorites() async {
    await _initPrefs();
    return _prefs?.getStringList(_favoritesKey) ?? [];
  }

  // Favorit hinzufügen
  Future<bool> addFavorite(String city) async {
    await _initPrefs();
    final favorites = Set<String>.from(await getFavorites());
    final added = favorites.add(city);

    if (added) {
      await _prefs?.setStringList(_favoritesKey, favorites.toList());
    }
    return added; // Gibt true zurück, wenn erfolgreich hinzugefügt
  }

  // Favorit entfernen
  Future<bool> removeFavorite(String city) async {
    await _initPrefs();
    final favorites = Set<String>.from(await getFavorites());
    final removed = favorites.remove(city);

    if (removed) {
      await _prefs?.setStringList(_favoritesKey, favorites.toList());
    }
    return removed; // Gibt true zurück, wenn erfolgreich entfernt
  }

  // Favoriten löschen
  Future<void> clearFavorites() async {
    await _initPrefs();
    await _prefs?.remove(_favoritesKey);
  }
}




