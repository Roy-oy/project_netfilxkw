import 'package:flutter/material.dart';
import 'package:project/models/movie_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<MovieModel> _favorites = [];

  List<MovieModel> get favorites => _favorites;

  bool isFavorite(int id) {
    return _favorites.any((movie) => movie.id == id);
  }

  void toggleFavorite(MovieModel movie) {
    if (isFavorite(movie.id)) {
      _favorites.removeWhere((item) => item.id == movie.id);
    } else {
      _favorites.add(movie);
    }
    notifyListeners();
  }
}
