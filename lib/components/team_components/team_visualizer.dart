import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/components/team_components/team.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/screens/team_screens/team_stats.dart';
import 'package:pokedex/screens/imc_pokemon_details.dart';
import 'package:pokedex/screens/team_screens/team_adder.dart';

//boton que permite visualizar e interactuar con equipo
class TeamVisualizer extends StatefulWidget {
  final Team team;
  const TeamVisualizer({super.key, required this.team});
  @override
  State<TeamVisualizer> createState() => _TeamVisualizerState(); // Crea estado.
}

class _TeamVisualizerState extends State<TeamVisualizer> {
  late List<Pokemon> pokemons;
  @override
  Widget build(BuildContext context) {
    final teams = context.watch<TeamsProvider>(); //llama a provider
    final String title = widget.team.title; //titulo del team
    final team = teams.getTeam(
      title,
    )!; //llama al team de nuevo por el nombre, esto permite evitar una variable "stale"

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
                ), //llama a dialog para cambiar nombre de equipo
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.note_add_outlined),
            tooltip: 'Agregar notas',
            onPressed: () {
              teams.editNotes(context, team);
            }, //llama dialog para editar o crear notas
          ),
          IconButton(
            icon: Icon(Icons.info),
            tooltip: 'Ver estadísticas del equipo',
            onPressed: () {
              if (pokemons.length != 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamStats(team: team),
                  ),
                ); //redirige a las estadísticas de equipo
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Equipo vacío'),
                      content: Text(
                        'No se pueden ver la estadísticas de $title porque está vacío',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // cierra dialog
                          },
                          child: const Text('Aceptar'),
                        ),
                      ],
                    );
                  },
                ); //si el equipo está vacío no abre estadísticas
              }
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
          ), //botón para eliminar al equipo (con todo lo que eso incluye)
        ],
        backgroundColor: const Color.fromARGB(255, 241, 87, 87),
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
          } // Indicator
          return Center(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
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
                          ? Center(
                              child: CircularProgressIndicator(),
                            ) //si no han cargado todos los pokemon sale circulo de carga y no permite añadir pokemon
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
                            ), //boton que lleva a pantalla para agregar pokemon al equipo
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
                          ), //tarjeta con nombre, id e imagen del pokémon
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
                          ), //boton para sacar al pokemon del equipo
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
              physics:
                  NeverScrollableScrollPhysics(), //evita que se pueda scrollear, pues todo debería calzar
              shrinkWrap: true,
            ),
          );
        },
      ),
    );
  }
}
