import 'package:flutter/material.dart';
import 'package:pokedex/data/lista_prueba.dart';

// === PokemonCardList.dart ===
// Widget para lista de tarjetas de Pokémon: Muestra tarjetas en un Wrap responsivo.
// Cada tarjeta es clickable, con nombre e imagen; usa datos pasados.
// Para PokeAPI: Recibir lista dinámica (filtrada); cargar imágenes de red (Image.network) de la api en lugar de asset.
class PokemonCardList extends StatefulWidget {
  final ListaPrueba pokemons;

  const PokemonCardList({super.key, required this.pokemons});

  @override
  State<PokemonCardList> createState() => _PokemonCardListState();
}

class _PokemonCardListState extends State<PokemonCardList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          alignment: WrapAlignment.start,
          children: widget.pokemons.pokemonList.map((pokemon) {
            return SizedBox(
              width: 320.0,
              height: 320.0,
              child: Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: InkWell(
                  onTap: () {
                    print('Seleccionado: ${pokemon.name}');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pokemon.name,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          pokemon.imagePath,
                          width: 110.0,
                          height: 110.0,
                          fit: BoxFit
                              .cover, // Cubre el área sin distorsión; corta si necesario, ideal para imágenes cuadradas.
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(), // Convierte el Iterable de map en List<Widget>; requerido por children.
          // Cambio con API: widget.pokemons sería List<Pokemon> de PokeAPI; usar Image.network(pokemon.spriteUrl).
          // Faltante: Manejo de lista vacía (mostrar "No resultados") o paginación infinita para grandes listas de PokeAPI.
        ),
      ),
    );
  }
}
