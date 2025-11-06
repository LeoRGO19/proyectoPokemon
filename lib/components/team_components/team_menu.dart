import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/screens/team_screens/team_manager.dart';

class Team {
  final String title;
  Set<String> deck = {};
  Team({required this.title});

  bool isTeamedUp(String poke) {
    return deck.contains(poke);
  }

  void add(String poke, BuildContext context) {
    if (deck.length < 6) {
      deck.add(poke);
    } else {
      _showMyDialog(context);
    }
  }

  void remove(String poke) {
    deck.remove(poke);
  }

  void pp() {
    print(deck);
  }

  void _showMyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Equipo lleno'),
          content: Text(
            '$title está lleno. ¿Desea ir al organizador de equipos?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamManager()),
                ); //redirige a manejador de equipos
              },
              child: const Text('Ir a organizador de equipos'),
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
