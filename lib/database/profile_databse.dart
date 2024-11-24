import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProfileDatabse {
  static Database? _database;
  static final ProfileDatabse instance = ProfileDatabse._();

  ProfileDatabse._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'video_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_videos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        videoUrl TEXT,
        userEmail TEXT,
        dateAdded TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE favorite_videos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movieId INTEGER,
        title TEXT,
        posterPath TEXT,
        userEmail TEXT,
        dateAdded TEXT
      )
    ''');
  }

  // CRUD Operations for User Videos
  Future<int> insertVideo(Map<String, dynamic> video) async {
    Database db = await database;
    return await db.insert('user_videos', video);
  }

  Future<List<Map<String, dynamic>>> getUserVideos(String userEmail) async {
    Database db = await database;
    return await db.query(
      'user_videos',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
    );
  }

  Future<int> updateVideo(Map<String, dynamic> video) async {
    Database db = await database;
    return await db.update(
      'user_videos',
      video,
      where: 'id = ?',
      whereArgs: [video['id']],
    );
  }

  Future<int> deleteVideo(int id) async {
    Database db = await database;
    return await db.delete(
      'user_videos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Operations for Favorite Videos
  Future<int> insertFavorite(Map<String, dynamic> favorite) async {
    Database db = await database;
    return await db.insert('favorite_videos', favorite);
  }

  Future<List<Map<String, dynamic>>> getFavorites(String userEmail) async {
    Database db = await database;
    return await db.query(
      'favorite_videos',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
    );
  }

  Future<int> deleteFavorite(int movieId, String userEmail) async {
    Database db = await database;
    return await db.delete(
      'favorite_videos',
      where: 'movieId = ? AND userEmail = ?',
      whereArgs: [movieId, userEmail],
    );
  }
}