import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/components/team_components/team.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:pokedex/core/text_styles.dart';

//boton que permite agregar pokemon a equipo
class BotonEquipo extends StatefulWidget {
  final Pokemon pokemon;

  const BotonEquipo({super.key, required this.pokemon});
  @override
  State<BotonEquipo> createState() => _BotonEquipoState(); // Crea estado.
}

class _BotonEquipoState extends State<BotonEquipo> {
  @override
  Widget build(BuildContext context) {
    final teams = context.watch<TeamsProvider>();
    return IconButton(
      onPressed: () {
        //print("hola");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                  child: SizedBox(
                    height: 320.0,
                    width: 300.0,
                    child: Consumer<TeamsProvider>(
                      //para que "escuche" cambios en los equipos
                      builder: (context, teams, _) {
                        final _items = teams.getTeams();
                        return Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Agregar pokémon a:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                // ListView para equipos
                                shrinkWrap: true,
                                children: <Widget>[
                                  Wrap(
                                    // Wrap para checkboxes.
                                    spacing: 10.0, // Espacio horizontal.
                                    runSpacing: 5.0, // Espacio vertical.
                                    alignment: WrapAlignment
                                        .start, // Alinea al inicio.
                                    children: _items.map((Team team) {
                                      // Mapea cada team.
                                      final isSelected = team.isTeamedUp(
                                        widget.pokemon.name,
                                      ); // Verifica si pokémon está en equipo.
                                      return SizedBox(
                                        // Tamaño fijo para cada item.
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                40) /
                                            3.5, // Ancho calculado.
                                        child: CheckboxListTile(
                                          // Tile con checkbox.
                                          title: Text(
                                            team.title,
                                            style: TextStyles.cardText,
                                          ), // Título de categoría.
                                          value:
                                              isSelected, // Valor del checkbox.
                                          onChanged: (value) {
                                            // Acción al cambiar.
                                            if (value != null) {
                                              // Si valor no nulo.
                                              setState(() {
                                                // Actualiza estado.
                                                if (value) {
                                                  // Si seleccionado.
                                                  teams.addPokemon(
                                                    team,
                                                    widget.pokemon.name,
                                                    context,
                                                  );
                                                } else {
                                                  teams.removePokemon(
                                                    team,
                                                    widget.pokemon.name,
                                                  );
                                                }
                                              });
                                            }
                                          },
                                          controlAffinity: ListTileControlAffinity
                                              .leading, // Checkbox al inicio.
                                          contentPadding:
                                              EdgeInsets.zero, // Sin padding.
                                          dense:
                                              true, // Denso para ahorrar espacio.
                                        ),
                                      );
                                    }).toList(), // Convierte a lista.
                                  ),
                                ], // Convierte a lista.
                              ),
                            ),
                            Visibility(
                              visible:
                                  (_items.length <
                                  10), //solo es posible crear equipos nuevos si hay menos de 10
                              child: IconButton(
                                icon: Icon(Icons.add),
                                iconSize: (_items.isEmpty) ? 40.0 : 20.0,
                                color: Colors.black,
                                tooltip: 'Crear equipo nuevo',
                                onPressed: () {
                                  setState(() {
                                    teams.namingTeam(context);
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                child: const Text('Cerrar'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      icon: Icon(Icons.add, size: 24.0, color: Colors.yellow),
    );
  }
}
