import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/data/favoriteWatcher.dart';
import 'package:pokedex/data/pokemon.dart';

class BotonFavorito extends StatelessWidget {
  final Pokemon pokemon;

  const BotonFavorito({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    // listen to provider
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorite(pokemon.name);

    return ElevatedButton(
      onPressed: () {
        favorites.toggleFavorite(pokemon.name);
      },

      child: Image.asset(
        isFav ? 'assets/images/fav.png' : 'assets/images/nofav.png',
        width: 50,
        height: 50,
      ),
    );
  }
}
