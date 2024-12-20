import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FavoriteService {
  Database? _database;

  Future<Database> initializeDB() async {
    if (_database != null) return _database!;
    String path = await getDatabasesPath();
    _database = await openDatabase(
      join(path, 'favorites.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE favorites(id INTEGER PRIMARY KEY AUTOINCREMENT, city TEXT NOT NULL, added_at TEXT NOT NULL)",
        );
      },
      version: 1,
    );
    return _database!;
  }

  Future<void> addFavorite(String cityName) async {
    if (cityName.isEmpty) {
      throw Exception('Stadtname darf nicht leer sein.');
    }

    try {
      final db = await initializeDB();
      await db.insert(
        'favorites',
        {
          'city': cityName,
          'added_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await _updateCache();
    } catch (e) {
      throw Exception('Fehler beim Hinzufügen zu den Favoriten: $e');
    }
  }

  Future<void> removeFavorite(String cityName) async {
    try {
      final db = await initializeDB();
      await db.delete('favorites', where: 'city = ?', whereArgs: [cityName]);
      await _updateCache();
    } catch (e) {
      throw Exception('Fehler beim Entfernen aus den Favoriten: $e');
    }
  }

  Future<List<String>> getFavorites() async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db.query('favorites');
      final favorites = queryResult.map((e) => e['city'] as String).toList();
      await _saveToCache(favorites);
      return favorites;
    } catch (e) {
      final cachedFavorites = await _loadFromCache();
      if (cachedFavorites != null) {
        return cachedFavorites;
      }
      throw Exception('Fehler beim Abrufen der Favoriten: $e');
    }
  }

  Future<void> _saveToCache(List<String> favorites) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/favorites_cache.json');
      await file.writeAsString(json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'favorites': favorites,
      }));
    } catch (e) {
      // Log cache save errors silently
    }
  }

  Future<List<String>?> _loadFromCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/favorites_cache.json');
      if (await file.exists()) {
        final data = json.decode(await file.readAsString()) as Map<String, dynamic>;
        if (_isCacheValid(data['timestamp'])) {
          return List<String>.from(data['favorites']);
        }
      }
    } catch (e) {
      // Log cache load errors silently
    }
    return null;
  }

  Future<void> _updateCache() async {
    final favorites = await getFavorites();
    await _saveToCache(favorites);
  }

  bool _isCacheValid(String timestamp) {
    final cacheTime = DateTime.parse(timestamp);
    return DateTime.now().difference(cacheTime).inHours <= 24;
  }
}




