import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*clase que sirve para notificar a todos los listeners asociados que un pokémon fue agregado o removido de favoritos, 
permitiendo que todas las iteraciones de este reflejen los cambios (como es en el caso de pokémon creados por la cadena evolutiva, 
que son diferentes a los pokémon de la lista principal de la pokédex)*/
class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  bool isFavorite(String name) => _favorites.contains(name);

  FavoritesProvider() {
    _loadFavorites();
  }

  ///carga la lista de favoritos desde SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedList = prefs.getStringList("favoritos");
    if (storedList != null) {
      _favorites.addAll(storedList);
      notifyListeners();
    }
  }

  //guarda los favoritos en shared preferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("favoritos", _favorites.toList());
  }

  void toggleFavorite(String name) async {
    //agrega o saca pokémon de la lista, dependiendo de su estado anterior
    if (_favorites.contains(name)) {
      _favorites.remove(name);
    } else {
      _favorites.add(name); //guardamos
    }
    notifyListeners(); // notifica a todos los listeners (principalmente BotonFavorito)
    await _saveFavorites();
  }

  void add(String name) async {
    _favorites.add(name);
    notifyListeners();
    await _saveFavorites(); //guardamos
  }

  void remove(String name) async {
    _favorites.remove(name);
    notifyListeners();
    await _saveFavorites(); //guardamos
  }
}
