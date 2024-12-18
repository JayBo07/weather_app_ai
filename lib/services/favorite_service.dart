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
          "CREATE TABLE favorites(id INTEGER PRIMARY KEY AUTOINCREMENT, city TEXT NOT NULL)",
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
      final existingFavorites = await getFavorites();
      if (!existingFavorites.contains(cityName)) {
        final db = await initializeDB();
        await db.insert(
          'favorites',
          {'city': cityName},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    } catch (e) {
      throw Exception('Fehler beim Hinzufügen zu den Favoriten: $e');
    }
  }

  Future<void> removeFavorite(String cityName) async {
    try {
      final db = await initializeDB();
      await db.delete('favorites', where: 'city = ?', whereArgs: [cityName]);
    } catch (e) {
      throw Exception('Fehler beim Entfernen aus den Favoriten: $e');
    }
  }

  Future<List<String>> getFavorites() async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db.query('favorites');
      return queryResult.map((e) => e['city'] as String).toList();
    } catch (e) {
      throw Exception('Fehler beim Abrufen der Favoriten: $e');
    }
  }
}


