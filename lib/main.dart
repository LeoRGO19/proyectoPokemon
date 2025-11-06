import 'package:flutter/material.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:pokedex/screens/menu_principal.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/data/favoriteWatcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
        ChangeNotifierProvider(create: (context) => TeamsProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MenuPrincipal());
  }
}
