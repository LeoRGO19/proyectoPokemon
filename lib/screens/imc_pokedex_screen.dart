import 'package:flutter/material.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/data/lista_prueba.dart';
import 'package:pokedex/components/pokedex_components/search_bar_widget.dart';
import 'package:pokedex/components/pokedex_components/category_filter_widget.dart';
import 'package:pokedex/components/pokedex_components/pokemon_card_list.dart';

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
  final ListaPrueba pokemons =
      ListaPrueba(); // Instancia de datos de prueba; en PokeAPI, usar Future o Provider para datos dinámicos.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SearchBarWidget(
            onChanged: (value) {
              // Placeholder para filtrado futuro
              print(
                'Buscando: $value',
              ); // Aquí iría la lógica real: setState con filtrado de pokemons por nombre.
              // Faltante: Actualizar una lista filtrada, ej: _filteredPokemons = pokemons.pokemonList.where((p) => p.name.contains(value)).toList();
              // Luego, pasar _filteredPokemons a PokemonCardList abajo.
            },
          ),
          CategoryFilterWidget(), // Widget de filtros; faltante: Pasar callback onFilterChanged para actualizar filtrado por categorías.
          // Ejemplo faltante: CategoryFilterWidget(onFilterChanged: (selected, mode) { setState(() { /* filtrar _filteredPokemons */ }); }),
          Expanded(child: PokemonCardList(pokemons: pokemons)),
          // Cambio con API: Pasar lista filtrada, ej: PokemonCardList(pokemons: _filteredPokemons ?? pokemons),
          // Faltante: Indicador de loading (CircularProgressIndicator) mientras fetch de PokeAPI.
        ],
      ),
    );
  }
}
