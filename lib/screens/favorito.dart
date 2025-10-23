import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';

class BotonFavorito extends StatefulWidget {
  //final String pokemon;
  final Pokemon pokemon; // Pokémon que es afectado por el favorito
  const BotonFavorito({super.key, required this.pokemon}); // Constructor.
  @override
  State<BotonFavorito> createState() => _BotonFavoritoState();
}

class _BotonFavoritoState extends State<BotonFavorito> {
  final List<Pokemon> _favoritePokemons = [];
  //final List<String> _favoritePokemons = [];

  late String _currentImagePath;

  @override
  void initState() {
    super.initState();
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
          _favoritePokemons.add(widget.pokemon);
          print("yipii");
        } else {
          _favoritePokemons.remove(widget.pokemon);
          print("no yipii");
        }
      },
      child: Image.asset(_currentImagePath, width: 50, height: 50),
    );
  }
}
