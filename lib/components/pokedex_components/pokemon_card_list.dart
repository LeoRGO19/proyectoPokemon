import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/core/text_styles.dart';

// === PokemonCardList.dart ===
// Widget para lista de tarjetas de Pokémon: Muestra tarjetas en un Wrap responsivo.
// Cada tarjeta es clickable, con nombre e imagen; usa datos pasados.
// Para PokeAPI: Recibir lista dinámica (filtrada); cargar imágenes de red (Image.network) de la api en lugar de asset.
class PokemonCardList extends StatelessWidget {
  final List<Pokemon> pokemons;

  const PokemonCardList({super.key, required this.pokemons});

  @override
  Widget build(BuildContext context) {
    if (pokemons.isEmpty) {
      return const Center(
        child: Text("No se encontraron Pokémon", style: TextStyles.bodyText),
      );
    }

    // Devuelve un padding con las imagenes de los pokemon en una lista
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: pokemons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final pokemon = pokemons[index];

          final id = pokemon.url.split("/")[6];
          final imageUrl =
              "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png";

          return Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              // Faltante: seleccion para las tarjetas individuales.
              onTap: () {
                debugPrint('Seleccionado: ${pokemon.name}');
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
                      width: 70.0,
                      height: 70.0,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 40, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
