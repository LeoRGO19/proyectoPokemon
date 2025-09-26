import 'package:flutter/material.dart';
import 'package:pokedex/components/pokedex_components/search_bar_widget.dart';
import 'package:pokedex/components/pokedex_components/category_filter_widget.dart';
import 'package:pokedex/components/pokedex_components/pokemon_card_list.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'package:pokedex/data/pokemon.dart';

// === ImcPokedexScreen.dart ===
// Pantalla principal de la Pokedex: Muestra el buscador, filtros y lista de Pokémon.
// Es el hub central; aquí se integran los widgets reutilizables.
// Para PokeAPI: En initState, fetch datos reales y almacena en listas como _allPokemons y _filteredPokemons.
// Faltante: Lógica de filtrado combinado (search + categorías); agregar callbacks para actualizar la lista filtrada y pasarla a PokemonCardList.
class ImcPokedexScreen extends StatefulWidget {
  const ImcPokedexScreen({super.key});

  @override
  State<ImcPokedexScreen> createState() => _ImcPokedexScreenState();
}

class _ImcPokedexScreenState extends State<ImcPokedexScreen> {
  // Lista con todos los pokemons, se llenara con la llamada a featchAllPokemon.
  List<Pokemon> _allPokemons = [];
  // Lista con los filtrados, se ira actualizando dependiendo de las circunstancias.
  List<Pokemon> _filteredPokemons = [];
  bool _isLoading = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _fetchPokemons();
  }

  // Uso de un Future para guardar los datos de manera practica
  Future<void> _fetchPokemons() async {
    try {
      final pokemons = await PokeApi.fetchAllPokemon();
      setState(() {
        _allPokemons = pokemons;
        _filteredPokemons = pokemons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterPokemons(String query) {
    final results = _allPokemons.where((pokemon) {
      return pokemon.name.toLowerCase().startsWith(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredPokemons = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text("Error: $_error"))
          : Column(
              children: [
                // Aqui esta el onChanged que lee el texto en la barra de busqueda
                SearchBarWidget(onChanged: (value) => _filterPokemons(value)),
                CategoryFilterWidget(), // todavía no implementa lógica
                Expanded(child: PokemonCardList(pokemons: _filteredPokemons)),
              ],
            ),
    );
  }
}
