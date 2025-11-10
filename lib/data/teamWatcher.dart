import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedex/components/team_components/team.dart';

/*clase que sirve para notificar a todos los listeners asociados que un pokémon fue agregado o removido de favoritos, 
permitiendo que todas las iteraciones de este reflejen los cambios (como es en el caso de pokémon creados por la cadena evolutiva, 
que son diferentes a los pokémon de la lista principal de la pokédex)*/
class TeamsProvider extends ChangeNotifier {
  final List<Team> _teams = [
    Team(title: 'Prueba 1'),
    Team(title: 'Prueba 2'),
    Team(title: 'Prueba 3'),
  ];
  List<Team> getTeams() {
    return _teams;
  }

  Team? getTeam(String equipo) {
    for (Team team in _teams) {
      if (team.title.toLowerCase() == equipo.toLowerCase()) {
        return team;
      }
    }
    return null;
  }

  void addPokemon(Team team, String name, BuildContext context) {
    team.add(name, context);
    notifyListeners();
  }

  void removePokemon(Team team, String name) {
    if (team.isTeamedUp(name)) {
      team.remove(name);
      notifyListeners();
    }
  }

  void addTeam(String equipo) {
    _teams.add(Team(title: equipo));
    notifyListeners();
  }

  void removeTeam(Team team) {
    _teams.remove(team);
    notifyListeners();
  }

  void namingTeam(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear equipo'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Ej: Equipo sombra',
                labelText: 'Nombre del equipo *',
                contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              ),
              onSaved: (String? value) {
                if (value != null) {
                  addTeam(value);
                  notifyListeners();
                }
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es obligatorio.';
                }
                if (getTeam(value) != null) {
                  return 'Ya existe un equipo con este nombre.';
                }

                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Aceptar'),
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
