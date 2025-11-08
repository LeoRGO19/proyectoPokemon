import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedex/components/team_components/team.dart';

/*clase que sirve para notificar a todos los listeners asociados que un pokémon fue agregado o removido de favoritos, 
permitiendo que todas las iteraciones de este reflejen los cambios (como es en el caso de pokémon creados por la cadena evolutiva, 
que son diferentes a los pokémon de la lista principal de la pokédex)*/
class TeamsProvider extends ChangeNotifier {
  final List<Team> _teams = [
    Team(title: 'Equipo 1'),
    Team(title: 'Equipo 2'),
    Team(title: 'Equipo 3'),
  ];
  List<Team> getTeams() {
    return _teams;
  }

  Team? getTeam(String title) {
    for (Team team in _teams) {
      if (team.title == title) {
        return team;
      }
    }
  }

  void add(Team team, String name, BuildContext context) {
    team.add(name, context);
    notifyListeners();
  }

  void remove(Team team, String name) {
    if (team.isTeamedUp(name)) {
      team.remove(name);
      notifyListeners();
    }
  }

  /* void toggleFavorite(Team teamie, String name) async {
    //agrega o saca pokémon de la lista, dependiendo de su estado anterior
    if (teamie.isTeamedUp(name)) {
      teamie.remove(name);
    } else {
      teamie.add(name); //guardamos
    }
    notifyListeners(); // notifica a todos los listeners (principalmente BotonFavorito)
    //await _saveFavorites();
  }*/
}
