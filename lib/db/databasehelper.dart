import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../favorite_screen.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _tableName = 'favorite_urls';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'favorites.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            alias TEXT NOT NULL,
            url TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<FavoriteUrl>> getAllFavoriteUrls() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (index) {
      return FavoriteUrl(
        alias: maps[index]['alias'],
        url: maps[index]['url'],
      );
    });
  }

  Future<void> insertFavoriteUrl(FavoriteUrl favoriteUrl) async {
    final db = await database;

    await db.insert(
      _tableName,
      {
        'alias': favoriteUrl.alias,
        'url': favoriteUrl.url,
      },
    );
  }

  Future<void> updateFavoriteUrlAlias(int id, String newAlias) async {
    final db = await database;

    await db.update(
      _tableName,
      {'alias': newAlias},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFavoriteUrl(int id) async {
    final db = await database;

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
