import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/components/team_components/team_menu.dart';
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
    final _items = teams.getTeams();
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
                    height: 300.0,
                    width: 300.0,
                    child: Column(
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
                                alignment:
                                    WrapAlignment.start, // Alinea al inicio.
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
                                      value: isSelected, // Valor del checkbox.
                                      onChanged: (value) {
                                        // Acción al cambiar.
                                        if (value != null) {
                                          // Si valor no nulo.
                                          setState(() {
                                            // Actualiza estado.
                                            if (value) {
                                              // Si seleccionado.
                                              team.add(
                                                widget.pokemon.name,
                                                context,
                                              );
                                            } else {
                                              if (team.isTeamedUp(
                                                widget.pokemon.name,
                                              )) {
                                                team.remove(
                                                  widget.pokemon.name,
                                                );
                                              }
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
                        // Optional: Add actions below the scrollable area
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
