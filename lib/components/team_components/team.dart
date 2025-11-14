import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/screens/team_screens/team_manager.dart';
import 'package:pokedex/data/pokeapi.dart';

//clase equipos, equipos pueden tener hasta 6 pokémon, que se pueden eliminar.
// cada equipo tiene nombre único y se le puede agregar notas
class Team {
  String title; //nombre del equipo
  final Set<String> deck; //nombres de pokemon en el equipo
  final List<Pokemon> pokemons; //pokemon en el equipo
  final Map<String, dynamic> details; //detalles de los pokemon del equipo
  String notes; //notas del equipo

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
  } //retorna true si pokemon es parte del equipo

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
  } //añade pokemon al equipo, y si equipo está lleno avisa

  void remove(String poke) {
    deck.remove(poke);
    pokemons.remove(_fetchFromList(poke)!);
  } //saca a pokemon del equipo

  Pokemon? _fetchFromList(String name) {
    for (Pokemon poke in pokemons) {
      if (poke.name.toLowerCase() == name.toLowerCase()) {
        return poke;
      }
    }
    return null;
  } //retorna pokemon de la lista por su nombre

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
  } //crea pokemon a partir de su nomre

  void renameTeam(String name) {
    title = name;
  } //cambia nombre del equipo

  void editNotes(String notas) {
    notes = notas;
  } //se editan las notas

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
  } //dialog que avisa si un equipo está lleno y redirige a manejador de equipos si el usuario lo desea

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
  } //transforma equipo a map para guardarlo en memoria

  //recontruye equipo desde un map (al recuperarlo de la memoria)
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
