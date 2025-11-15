import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedex/components/team_components/team.dart';

/*clase que sirve para notificar a todos los listeners asociados que un equipo fue creado o eliminado, de si se le cambió el nombre, 
, se le agregaron notas o se agregaron o eliminaron notas;permitiendo que todas las iteraciones de estos reflejen los cambios, y los pokemon sepan a qué equipo(s) pertenecen */
class TeamsProvider extends ChangeNotifier {
  final List<Team> _teams = [];

  TeamsProvider() {
    _loadTeams();
  } //carga equipos desde memoria

  ///carga la lista de equipos desde SharedPreferences
  Future<void> _loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.clear(); esto es por si la memoria se "corrompe" o queda con cosas innecesarias
    final List<String>? storedList = prefs.getStringList("teams");
    if (storedList != null) {
      _teams.addAll(toTeam(storedList));
      notifyListeners();
    }
  }

  //guarda los equipos en shared preferences, transformando cada uno en map y agregandolo a una lista
  Future<void> _saveTeams() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("teams", toIterable(_teams));
  }

  //cuando carga lista desde memoria cada map lo transforma en equipo y lo agrega a la lista de equipos
  List<Team> toTeam(List<String> saved) {
    List<Team> equipos = [];

    for (String teamString in saved) {
      Map<String, dynamic> data = jsonDecode(teamString);
      equipos.add(Team.fromMap(data));
    }

    return equipos;
  }

  //transforma la lista de equipos en una lista de string, esto pasando cada lista a map y luego los map a string
  List<String> toIterable(List<Team> equipos) {
    return equipos.map((team) => jsonEncode(team.toMap())).toList();
  }

  //metodo auxiliar por si hay que notificar de algo
  void notify() {
    notifyListeners();
  }

  //retorna equipos
  List<Team> getTeams() {
    return _teams;
  }

  //retorna equipo basado en su nombre
  Team? getTeam(String equipo) {
    for (Team team in _teams) {
      if (team.title.toLowerCase() == equipo.toLowerCase()) {
        return team;
      }
    }
    return null;
  }

  //añade pokemon a equipo y avisa a listeners
  void addPokemon(Team team, String name, BuildContext context) async {
    team.add(name, context, onUpdated: notifyListeners);
    notifyListeners();
    await _saveTeams();
  }

  //saca pokemon de equipo y avisa a listeners
  void removePokemon(Team team, String name) async {
    if (team.isTeamedUp(name)) {
      team.remove(name);
      notifyListeners();
      await _saveTeams();
    }
  }

  //crea team y lo añade a lista
  void addTeam(String equipo) async {
    _teams.add(Team(title: equipo));
    notifyListeners();
    await _saveTeams();
  }

  //saca equipo de la lista, "borrándolo"
  void removeTeam(Team team) async {
    _teams.remove(team);
    notifyListeners();
    await _saveTeams();
  }

  //renombra equipo
  void renamingTeam(Team team, String name) async {
    team.renameTeam(name);
    notifyListeners();
    await _saveTeams();
  }

  //despliega dialog que permite editar las notas de un equipo dado
  void editNotes(BuildContext context, Team team) async {
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
                    decoration: InputDecoration(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () async {
                    final text = controller.text.trim();

                    if (text.isEmpty) {
                      setState(() {});
                      return;
                    } //si no se ha ingresado nada no permite mandar
                    team.editNotes(text);
                    notifyListeners();
                    await _saveTeams();
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

  //despliega dialog que dependiendo de parametros nombra equipo nuevo o renombra equipo ya creado
  void namingTeam(
    BuildContext context,
    bool creating,
    String? title,
    Team? team,
  ) async {
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
              onSaved: (String? value) async {
                if (value != null) {
                  if (creating) {
                    addTeam(value);
                    notifyListeners();
                  } else {
                    renamingTeam(team!, value);
                  }
                  await _saveTeams();
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
}
