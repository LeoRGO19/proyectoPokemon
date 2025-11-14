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

  void notify() {
    notifyListeners();
    //print('notice');
  }

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
    team.add(name, context, onUpdated: notifyListeners);
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

  void renamingTeam(Team team, String name) {
    team.renameTeam(name);
    notifyListeners();
  }

  void editNotes(BuildContext context, Team team) {
    String initial = team.notes;
    final controller = TextEditingController(text: initial);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Notas sobre el equipo"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: null,
                    autofocus: true,
                    decoration: InputDecoration(
                      // labelText: "  Notas",
                      //border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    final text = controller.text.trim();

                    if (text.isEmpty) {
                      setState(() {});
                      return;
                    }
                    team.editNotes(text);
                    notifyListeners();
                    Navigator.pop(context);
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void namingTeam(
    BuildContext context,
    bool creating,
    String? title,
    Team? team,
  ) {
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: (creating)
              ? Text('Crear equipo')
              : Text('Ingrese el nuevo nombre de $title'),
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
                  if (creating) {
                    addTeam(value);
                    notifyListeners();
                  } else {
                    renamingTeam(team!, value);
                  }
                }
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es obligatorio.';
                }
                if (!creating && value == title) {
                  return 'Este es el nombre actual del equipo.';
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
