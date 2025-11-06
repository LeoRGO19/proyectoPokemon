import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/components/team_components/team_menu.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:provider/provider.dart';

//boton que permite agregar pokemon a equipo
class TeamManager extends StatefulWidget {
  const TeamManager({super.key});
  @override
  State<TeamManager> createState() => _TeamManagerState(); // Crea estado.
}

class _TeamManagerState extends State<TeamManager> {
  @override
  Widget build(BuildContext context) {
    final teams = context.watch<TeamsProvider>();
    final _items = teams.getTeams();
    return Scaffold(
      appBar: AppBar(
        title: Text('Manejador de Equipos', style: TextStyles.bodyText),
        backgroundColor: AppColors.backgroundComponentSelected,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: AppColors.fondoPokedex,
        child: Column(children: [
            
          ],
        ),
      ),
    );
  }
}
