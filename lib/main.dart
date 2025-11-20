import 'package:flutter/material.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:pokedex/screens/menu_principal.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/data/favoriteWatcher.dart';
import 'dart:isolate';
import 'package:pokedex/services/database_services.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> _loadInitialDataInIsolate(List<dynamic> args) async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final SendPort sendPort = args[0] as SendPort;
  final fetcher = args[1] as Future<List<Pokemon>> Function(int, int);

  try {
    // Llama al método de la DB, que a su vez usa el fetcher para obtener detalles.
    await DatabaseService.instance.loadInitialData(fetcher);
    sendPort.send(true); // Éxito
  } catch (e) {
    print('Error en Isolate de carga inicial: $e');
    sendPort.send(false); // Fallo
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit(); // Inicializa FFI
  databaseFactory = databaseFactoryFfi;
  // 1. Definición del fetcher que usará el Isolate (llamando al método que trae detalles)
  Future<List<Pokemon>> pokeApiFetcher(int offset, int limit) async {
    // Usamos el método que trae TODOS los detalles necesarios para el filtro.
    return PokeApi.fetchBatchWithDetails(offset: offset, limit: limit);
  }

  // 2. Carga inicial de datos si la base de datos está incompleta
  print('Iniciando chequeo y carga de Pokédex completa...');

  final receivePort = ReceivePort();

  // Ejecutamos la carga en un Isolate
  await Isolate.spawn(_loadInitialDataInIsolate, [
    receivePort.sendPort,
    pokeApiFetcher,
  ]);

  // Esperamos el resultado del Isolate antes de continuar
  await receivePort.first;

  print('Carga inicial completada (o base de datos verificada).');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FavoritesProvider(),
        ), //provider de favoritos
        ChangeNotifierProvider(
          create: (context) => TeamsProvider(),
        ), //provider de equipos
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
