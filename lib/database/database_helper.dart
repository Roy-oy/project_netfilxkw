// import 'dart:async';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   static Database? _database;

//   DatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     return openDatabase(
//       join(dbPath, 'favorites.db'),
//       onCreate: (db, version) {
//         return db.execute('''
//           CREATE TABLE favorites(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             title TEXT,
//             posterPath TEXT
//           )
//         ''');
//       },
//       version: 1,
//     );
//   }

//   Future<void> insertFavorite(String title, String posterPath) async {
//   final db = await database;
//   await db.insert(
//     'favorites',
//     {
//       'title': title.isNotEmpty ? title : 'Unknown Title',
//       'posterPath': posterPath.isNotEmpty ? posterPath : '',
//     },
//     conflictAlgorithm: ConflictAlgorithm.replace,
//   );
// }

//   Future<List<Map<String, dynamic>>> getFavorites() async {
//     final db = await database;
//     return await db.query('favorites');
//   }

//   Future<void> addFavorite(String title, String posterPath) async {
//     final db = await database;
//     await db.insert(
//       'favorites',
//       {'title': title, 'posterPath': posterPath},
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<void> removeFavorite(String title) async {
//     final db = await database;
//     await db.delete('favorites', where: 'title = ?', whereArgs: [title]);
//   }
// }
