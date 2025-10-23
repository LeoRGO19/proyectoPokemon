import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/main.dart';
import 'package:pokedex/screens/menu_principal.dart';

class BotonFavorito extends StatefulWidget {
  final Pokemon pokemon; // Pokémon que es afectado por el favorito
  const BotonFavorito({super.key, required this.pokemon}); // Constructor.
  @override
  State<BotonFavorito> createState() => _BotonFavoritoState();
}

class _BotonFavoritoState extends State<BotonFavorito> {
  late String _currentImagePath;

  @override
  void initState() {
    super.initState();
    widget.pokemon.checkFav();
    _currentImagePath = widget.pokemon.isFav
        ? 'assets/images/fav.png'
        : 'assets/images/nofav.png';
  }

  void _toggleImage() {
    setState(() {
      widget.pokemon.changeFav();
      _currentImagePath = widget.pokemon.isFav
          ? 'assets/images/fav.png'
          : 'assets/images/nofav.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _toggleImage();
        if (widget.pokemon.isFav) {
          MainApp.favoritePokemons.add(widget.pokemon.name);
        } else {
          MainApp.favoritePokemons.remove(widget.pokemon.name);
        }
      },
      child: Image.asset(_currentImagePath, width: 50, height: 50),
    );
  }
}
