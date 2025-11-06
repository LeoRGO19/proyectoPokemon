import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/components/team_components/team_menu.dart';
import 'package:pokedex/core/text_styles.dart';

//boton que permite agregar pokemon a equipo
class TeamManager extends StatefulWidget {
  const TeamManager({super.key});
  @override
  State<TeamManager> createState() => _TeamManagerState(); // Crea estado.
}

class _TeamManagerState extends State<TeamManager> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print("hola");
      },
      child: Text("Hola"),
    );
  }
}
