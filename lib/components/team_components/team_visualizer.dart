import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/components/team_components/team.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/screens/team_screens/team_stats.dart';
import 'package:pokedex/screens/imc_pokemon_details.dart';
import 'package:pokedex/screens/team_screens/team_adder.dart';

//boton que visualizar e interactuar con equipo
class TeamVisualizer extends StatefulWidget {
  final Team team;
  const TeamVisualizer({super.key, required this.team});
  @override
  State<TeamVisualizer> createState() => _TeamVisualizerState(); // Crea estado.
}

class _TeamVisualizerState extends State<TeamVisualizer> {
  late List<Pokemon> pokemons;
  /* @override
  void initState() {
    super.initState();
    pokemons = widget.team.pokemons;
  }*/

  @override
  Widget build(BuildContext context) {
    final teams = context.watch<TeamsProvider>();
    final String title = widget.team.title;
    final team = teams.getTeam(title)!;

    /*if (widget.team.deck.isEmpty) {
      // Si vacío
      return Center(
        child: Text(title + " está vacio"), // Mensaje.
      );
    }*/ /* else if (pokemons.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }*/

    return Scaffold(
      // Scaffold base.
      backgroundColor: Colors.transparent, // Fondo oscuro.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Consumer<TeamsProvider>(
          //para que "escuche" cambios en los equipos
          builder: (context, teams, _) {
            final Team team = teams.getTeam(
              title,
            )!; //nos aseguramos de que el equipo se actualice
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyles.bodyText),
                SizedBox(width: 8),
                IconButton(
                  tooltip: 'Cambiar nombre de equipo',
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    teams.namingTeam(context, false, title, team);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            tooltip: 'Ver estadísticas del equipo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeamStats(team: team)),
              ); //redirige a las estadísticas de equipo
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Eliminar equipo',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Eliminar equipo'),
                    content: Text(
                      '¿Desea eliminar $title? Esta acción es permanente.',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          teams.removeTeam(team);
                        },
                        child: const Text('Eliminar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // cierra dialog
                        },
                        child: const Text('Cancelar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 241, 87, 87),
        /*leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),*/
      ),
      body: Consumer<TeamsProvider>(
        //para que "escuche" cambios en los equipos
        builder: (context, teams, _) {
          final Team team = teams.getTeam(
            title,
          )!; //nos aseguramos de que el equipo se actualice
          pokemons = team.pokemons;
          if (pokemons.isEmpty && team.deck.isNotEmpty) {
            // Condicional para loading.
            return Center(child: CircularProgressIndicator());
          } // Indicator.
          return Center(
            child: GridView.builder(
              padding: const EdgeInsets.all(6.0),
              itemCount: (pokemons.length < 6)
                  ? pokemons.length + 1
                  : pokemons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, // 6 columnas
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                if (index == pokemons.length) {
                  return Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      // Shape redondeado.
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: (pokemons.length != team.deck.length)
                          ? Center(child: CircularProgressIndicator())
                          : IconButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdderPokemonScreen(title: title),
                                  ),
                                );
                                setState(() {});
                              },
                              tooltip: "Agregar pokémon al equipo",
                              icon: Icon(
                                Icons.add,
                                size: 60.0,
                                color: Colors.blueGrey,
                              ),
                            ),
                    ),
                  );
                } else {
                  if (index < team.deck.length) {
                    // Si item real.
                    final pokemon = pokemons[index];
                    final id =
                        team.details[pokemon
                            .name]?['id']; //evitamos que hayan errores si id aún no carga
                    if (id == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final imageUrl =
                        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png"; // Arte con mejor calidad.

                    return Card(
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        // Shape redondeado.
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              // Clickable.
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PokemonDetailScreen(pokemon: pokemon),
                                  ),
                                );
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
                                      loadingBuilder:
                                          (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => // Error.
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
                          ),
                          Positioned(
                            bottom: 0.0,
                            right: 0.0,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: FloatingActionButton(
                                heroTag:
                                    pokemon.name +
                                    team.title, //tags unicos para evitar conflictos en los widget trees
                                backgroundColor: Colors.transparent,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Sacar Pokémon de equipo',
                                        ),
                                        content: Text(
                                          '¿Desea sacar a ${pokemon.name} del equipo?',
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              teams.removePokemon(
                                                team,
                                                pokemon.name,
                                              );
                                            },
                                            child: const Text('Eliminar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pop(); // cierra dialog
                                            },
                                            child: const Text('Cancelar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                elevation: 0.0,
                                disabledElevation: 0.0,
                                tooltip: 'Eliminar',
                                hoverColor: Colors.transparent,
                                highlightElevation: 0.0,
                                focusElevation: 0.0,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Padding(
                      // Loading item.
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                }
              },
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
          );
        },
      ),
    );
  }
}
