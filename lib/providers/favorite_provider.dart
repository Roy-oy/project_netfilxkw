import 'package:flutter/material.dart';
import 'package:project/models/movie_detail_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteProvider extends ChangeNotifier {
  final List<MovieDetailModel> _favorites = [];
  static const String _storageKey = 'favorite_movies';

  FavoriteProvider() {
    _loadFavorites();
  }

  List<MovieDetailModel> get favorites => _favorites;

  bool isFavorite(int id) {
    return _favorites.any((movie) => movie.id == id);
  }

  Future<void> toggleFavorite(MovieDetailModel movie) async {
    if (isFavorite(movie.id)) {
      _favorites.removeWhere((item) => item.id == movie.id);
    } else {
      _favorites.add(movie);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _favorites
          .map((movie) => {
                'id': movie.id,
                'title': movie.title,
                'overview': movie.overview,
                'posterPath': movie.posterPath,
                'backdropPath': movie.backdropPath,
                'voteAverage': movie.voteAverage,
                'voteCount': movie.voteCount,
                'releaseDate': movie.releaseDate.toIso8601String(),
              })
          .toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_storageKey);

    if (encodedData != null) {
      final List<dynamic> decodedData = json.decode(encodedData);
      _favorites.clear();
      _favorites.addAll(
        decodedData.map((item) => MovieDetailModel(
              id: item['id'],
              title: item['title'],
              overview: item['overview'],
              posterPath: item['posterPath'],
              backdropPath: item['backdropPath'],
              voteAverage: item['voteAverage'].toDouble(),
              voteCount: item['voteCount'],
              releaseDate: DateTime.parse(item['releaseDate']),
              adult: false,
              budget: 0,
              genres: [],
              homepage: '',
              popularity: 0,
              revenue: 0,
              runtime: 0,
              status: '',
              tagline: '',
            )),
      );
      notifyListeners();
    }
  }
}
