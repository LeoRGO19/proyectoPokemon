import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';

class Team {
  final String title;
  Set<String> deck = {};
  Team({required this.title});

  bool isTeamedUp(String poke) {
    return deck.contains(poke);
  }

  void add(String poke) {
    deck.add(poke);
  }

  void remove(String poke) {
    deck.remove(poke);
  }

  void pp() {
    print(deck);
  }
}
