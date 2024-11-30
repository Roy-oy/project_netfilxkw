import 'package:flutter/material.dart';
import 'package:project/models/movie_detail_model.dart';
import 'package:project/repostories/movie_repository.dart';

class MovieGetDetailProvider with ChangeNotifier {
  final MovieRepository _movieRepository;

  MovieGetDetailProvider(this._movieRepository);

  MovieDetailModel? _movie;
  MovieDetailModel? get movie => _movie;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void getDetail(BuildContext context, {required int id}) async {
    _isLoading = true;
    _movie = null;
    notifyListeners();

    final result = await _movieRepository.getDetail(id: id);

    result.fold(
      (messageError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(messageError)),
        );
        _movie = null;
        _isLoading = false;
        notifyListeners();
        return;
      },
      (response) {
        _movie = response;
        _isLoading = false;
        notifyListeners();
        return;
      },
    );
  }
}
