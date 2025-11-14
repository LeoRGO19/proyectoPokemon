import 'package:flutter/material.dart';
import 'package:pokedex/components/team_components/team_visualizer.dart';
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
  void dispose() {
    // Limpia.
    // _scrollController.dispose();
    super.dispose();
  }

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
        child: Stack(
          children: [
            ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 300,
                    maxHeight: 360, // puedes ajustarlo
                  ),
                  child: TeamVisualizer(team: _items[index]),
                );
              },
              /*separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },*/
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Visibility(
                visible: (_items.length < 10),
                //solo es posible crear equipos nuevos si hay menos de 10
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    heroTag: "fab2",
                    backgroundColor: AppColors.backgroundComponentSelected,
                    onPressed: () {
                      setState(() {
                        teams.namingTeam(context, true, null, null);
                      });
                    },
                    tooltip: 'Crear equipo nuevo',
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
