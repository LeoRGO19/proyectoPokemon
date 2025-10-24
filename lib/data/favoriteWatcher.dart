import 'package:flutter/material.dart';

/*clase que sirve para notificar a todos los listeners asociados que un pokémon fue agregado o removido de favoritos, 
permitiendo que todas las iteraciones de este reflejen los cambios (como es en el caso de pokémon creados por la cadena evolutiva, 
que son diferentes a los pokémon de la lista principal de la pokédex)*/
class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  bool isFavorite(String name) => _favorites.contains(name);

  void toggleFavorite(String name) {
    //agrega o saca pokémon de la lista, dependiendo de su estado anterior
    if (_favorites.contains(name)) {
      _favorites.remove(name);
    } else {
      _favorites.add(name);
    }
    notifyListeners(); // notifica a todos los listeners (principalmente BotonFavorito)
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
