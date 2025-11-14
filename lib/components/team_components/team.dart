import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/screens/team_screens/team_manager.dart';
import 'package:pokedex/data/pokeapi.dart';

class Team {
  String title;
  final Set<String> deck;
  final List<Pokemon> pokemons;
  final Map<String, dynamic> details;
  String notes;

  Team({
    required this.title,
    Set<String>? deck,
    List<Pokemon>? pokemons,
    Map<String, dynamic>? details,
    this.notes = '',
  }) : deck = deck ?? <String>{},
       pokemons = pokemons ?? <Pokemon>[],
       details = details ?? <String, dynamic>{};

  bool isTeamedUp(String poke) {
    return deck.contains(poke);
  }

  void add(String poke, BuildContext context, {VoidCallback? onUpdated}) {
    if (deck.length < 6) {
      deck.add(poke);
      fetchPokemon(
        poke,
        onUpdated: onUpdated,
      ); //nos aseguramos de que se actualizó para notificar
    } else {
      _showMyDialog(context);
    }
  }

  void remove(String poke) {
    deck.remove(poke);
    pokemons.remove(_fetchFromList(poke)!);
  }

  Pokemon? _fetchFromList(String name) {
    for (Pokemon poke in pokemons) {
      if (poke.name.toLowerCase() == name.toLowerCase()) {
        return poke;
      }
    }
    return null;
  }

  void fetchPokemon(String name, {VoidCallback? onUpdated}) async {
    Pokemon? poke = await PokeApi.fetchPokemonByName(name);
    if (poke != null) {
      pokemons.add(poke);
      _fetchDetails(poke).then((data) {
        details[name] = data;
        if (onUpdated != null)
          onUpdated(); // notificamos al provider de que cargamos detalles
      });
      if (onUpdated != null) onUpdated(); // notificamos provider
    }
  }

  void renameTeam(String name) {
    title = name;
  }

  void editNotes(String notas) {
    notes = notas;
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

  Future<Map<String, dynamic>?> _fetchDetails(Pokemon pokemon) async {
    // Función para fetch todos los datos.
    try {
      // Try-catch para errores.
      final Map<String, dynamic> details =
          await PokeApi.fetchPokemonFullDetails(
            pokemon.url,
          ); // Fetch detalles full.
      return details;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> poke = [];
    for (Pokemon p in pokemons) {
      poke.add(p.toMap());
    }
    return {
      'title': title,
      'deck': jsonEncode(deck.toList()),
      'pokemons': jsonEncode(poke),
      'details': details,
      'notes': notes,
    };
  }

  //construye el pokemon a partir de la base de datos
  factory Team.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> poke = List<Map<String, dynamic>>.from(
      jsonDecode(map['pokemons']),
    );
    List<Pokemon> pokemones = [];
    for (Map<String, dynamic> p in poke) {
      pokemones.add(Pokemon.fromMap(p));
    }
    return Team(
      title: map['title'],
      deck: Set<String>.from(jsonDecode(map['deck'])),
      pokemons: pokemones,
      details: Map<String, dynamic>.from(map['details']),
      notes: map['notes'],
    );
  }
}
