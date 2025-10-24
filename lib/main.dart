import 'package:flutter/material.dart';
import 'package:pokedex/screens/menu_principal.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/data/favoriteWatcher.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoritesProvider(),
      child: const MainApp(),
    ),
  );
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
