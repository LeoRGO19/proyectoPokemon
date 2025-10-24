import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  bool isFavorite(String name) => _favorites.contains(name);

  void toggleFavorite(String name) {
    if (_favorites.contains(name)) {
      _favorites.remove(name);
    } else {
      _favorites.add(name);
    }
    notifyListeners(); // notify all listeners (like BotonFavorito)
  }

  void add(String name) {
    _favorites.add(name);
    notifyListeners();
  }

  void remove(String name) {
    _favorites.remove(name);
    notifyListeners();
  }
}
