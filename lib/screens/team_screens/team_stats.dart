import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/components/team_components/team_visualizer.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/components/team_components/team.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:provider/provider.dart';

//boton que permite agregar pokemon a equipo
class TeamStats extends StatefulWidget {
  final Team team;
  const TeamStats({super.key, required this.team});
  @override
  State<TeamStats> createState() => _TeamStatsState(); // Crea estado.
}

class _TeamStatsState extends State<TeamStats> {
  @override
  void dispose() {
    // Limpia.
    // _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.team.title;
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas de $title', style: TextStyles.bodyText),
        backgroundColor: AppColors.backgroundComponentSelected,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: AppColors.fondoPokedex,
        child: Center(child: Text('Esto debería tener estadísticas')),
      ),
    );
  }
}
