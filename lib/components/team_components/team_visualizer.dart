import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/components/team_components/team.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:provider/provider.dart';

//boton que permite agregar pokemon a equipo
class TeamVisualizer extends StatefulWidget {
  final Team team;
  const TeamVisualizer({super.key, required this.team});
  @override
  State<TeamVisualizer> createState() => _TeamVisualizerState(); // Crea estado.
}

class _TeamVisualizerState extends State<TeamVisualizer> {
  late List<Pokemon> pokemons;
  @override
  void initState() {
    super.initState();
    pokemons = widget.team.pokemons;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.team.deck.isEmpty) {
      // Si vacío
      return Center(
        child: Text(widget.team.title + " está vacio"), // Mensaje.
      );
    } /* else if (pokemons.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }*/

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: pokemons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // 6 columnas
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        if (index < pokemons.length) {
          // Si item real.
          final pokemon = pokemons[index];
          final id = widget.team.details[pokemon.name]['id'];
          final imageUrl =
              "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png"; // Arte con mejor calidad.

          return Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              // Shape redondeado.
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              // Clickable.
              onTap: () {
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                  ),
                );*/
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
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }
}
