import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/core/text_styles.dart';

// Widget para lista de cards de Pokémon en grid.
// Muestra ID, nombre, imagen; clickable a details.
// Funciona con GridView.builder
// Muestra la lista filtrada con loading queda por cargar.

class PokemonCardList extends StatelessWidget {
  final List<Pokemon> pokemons; // Lista a mostrar.
  final ScrollController scrollController; // Controller.
  final bool isLoading; // Loading.
  final bool hasMore; // More.
  final void Function(Pokemon pokemon) onSelected;
  final bool Function(Pokemon pokemon) isSelected;

  const PokemonCardList({
    super.key,
    required this.pokemons,
    required this.scrollController,
    required this.isLoading,
    required this.hasMore,
    required this.onSelected,
    required this.isSelected,
  });
  @override
  Widget build(BuildContext context) {
    // Build.
    if (pokemons.isEmpty) {
      // Si vacío.
      if (isLoading) {
        // Si loading.
        return const Center(child: CircularProgressIndicator()); // Indicator.
      } else if (!hasMore) {
        // No more.
        return const Center(
          child: Text(
            "No se encontraron Pokémon",
            style: TextStyles.bodyText,
          ), // Mensaje.
        );
      } else {
        return const Center(child: CircularProgressIndicator()); // Indicator.
      }
    }

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: pokemons.length + (isLoading ? 1 : 0), // Count + loading.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // 6 columnas.
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        if (index < pokemons.length) {
          // Si item real.
          final pokemon = pokemons[index];
          final id = pokemon.url.split("/")[6];
          final imageUrl =
              "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png"; // Arte con mejor calidad.
          final bool isPokemonSelected = isSelected(pokemon);
          return Card(
            elevation: isPokemonSelected ? 8.0 : 3.0,
            shape: RoundedRectangleBorder(
              // Shape redondeado.
              borderRadius: BorderRadius.circular(10.0),
              side: isPokemonSelected
                  ? const BorderSide(
                      color: Colors.blueAccent,
                      width: 3.0,
                    ) // Borde
                  : BorderSide.none,
            ),
            child: InkWell(
              // Clickable.
              onTap: () {
                onSelected(pokemon);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "#$id ${pokemon.name.toUpperCase()}",
                    style: TextStyles.cardText,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      width: 150.0,
                      height: 150.0,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) => // Error.
                          const Icon(
                            Icons.error,
                            size: 40,
                            color: Colors.red,
                          ), // Icon.
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Padding(
            // Loading item.
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
