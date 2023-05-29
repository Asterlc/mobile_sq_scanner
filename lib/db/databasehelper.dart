import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../screens/favorite_screen.dart';

class FavoriteRecord {
  int id;
  late String _alias;
  final String url;

  FavoriteRecord({
    required this.id,
    required String alias,
    required this.url,
  }) : _alias = alias;

  String get alias => _alias;

  set alias(String newAlias) {
    _alias = newAlias;
  }
}

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

  Future<List<FavoriteRecord>> getAllFavoriteUrls() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (index) {
      return FavoriteRecord(
        id: maps[index]['id'],
        alias: maps[index]['alias'],
        url: maps[index]['url'],
      );
    });
  }

  Future<int> insertFavoriteUrl(FavoriteUrl favoriteUrl) async {
    final db = await database;

    int id = await db.insert(
      _tableName,
      {
        'alias': favoriteUrl.alias,
        'url': favoriteUrl.url,
      },
    );

    return id;
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
