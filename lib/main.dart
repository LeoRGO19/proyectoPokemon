import 'package:flutter/material.dart';
import 'package:pokedex/screens/menu_principal.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  static List<String> favoritePokemons =
      []; //lista donde los pokémon favoritos son guardados
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MenuPrincipal());
  }
}
