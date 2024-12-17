import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:project/models/movie_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'movies.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE movies(
            id INTEGER PRIMARY KEY,
            title TEXT,
            overview TEXT,
            posterPath TEXT,
            backdropPath TEXT,
            voteAverage REAL,
            voteCount INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertMovie(MovieModel movie) async {
    final db = await database;
    return await db.insert(
      'movies',
      {
        'id': movie.id,
        'title': movie.title,
        'overview': movie.overview,
        'posterPath': movie.posterPath,
        'backdropPath': movie.backdropPath,
        'voteAverage': movie.voteAverage,
        'voteCount': movie.voteCount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MovieModel>> getAllMovies() async {
    final db = await database;
    final movies = await db.query('movies');
    return movies.map((movie) => MovieModel.fromMap(movie)).toList();
  }

  Future<int> deleteMovie(int id) async {
    final db = await database;
    return await db.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<MovieModel?> getMovieById(int id) async {
    final db = await database;
    final results = await db.query(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return MovieModel.fromMap(results.first);
    } else {
      return null;
    }
  }
}
