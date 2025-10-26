import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/data/favoriteWatcher.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/core/app_colors.dart';

//boton que permite marcar a un pokémon como favorito
class BotonFavorito extends StatelessWidget {
  final Pokemon pokemon;

  const BotonFavorito({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    // escucha a provider por cambios
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorite(pokemon.name);

    return ElevatedButton(
      onPressed: () {
        favorites.toggleFavorite(pokemon.name);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.fontoTituloDetalle,
        splashFactory: NoSplash.splashFactory,
      ),

      child: Image.asset(
        isFav ? 'assets/images/fullStar.png' : 'assets/images/hollowStar.png',
        width: 70,
        height: 70,
      ),
    );
  }
}
