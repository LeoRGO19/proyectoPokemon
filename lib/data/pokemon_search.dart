import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';

class PokedexSearch extends StatefulWidget {
  final List<Pokemon> pokemons;

  const PokedexSearch({super.key, required this.pokemons});

  @override
  State<PokedexSearch> createState() => _PokedexSearchState();
}

class _PokedexSearchState extends State<PokedexSearch> {
  List<Pokemon> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = widget.pokemons;
  }

  void _filterPokemons(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = widget.pokemons;
      } else {
        _filteredList = widget.pokemons
            .where(
              (pokemon) =>
                  pokemon.name.toLowerCase().startsWith(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Buscar Pokémon...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _filterPokemons,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredList.length,
            itemBuilder: (context, index) {
              final pokemon = _filteredList[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Text(
                    pokemon.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(pokemon.name),
                subtitle: Text(pokemon.url),
              );
            },
          ),
        ),
      ],
    );
  }
}
