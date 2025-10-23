// Clase modelo para Pokémon.
// Representa data básica y extendida.
// Funciona con factories para fromJson y withDetails.
// Objetivo: Almacenar data fetched para UI y filtros.
import 'package:pokedex/main.dart';
import 'package:pokedex/screens/menu_principal.dart';

class Pokemon {
  final String name;
  final String url;
  final List<String> types;
  final String generation;
  final bool isLegendary;
  final bool isMythical;
  final String color;
  final String? habitat;
  final String? shape;
  final List<String> eggGroups;
  late bool isFav;

  Pokemon({
    required this.name,
    required this.url,
    this.types = const [],
    this.generation = '',
    this.isLegendary = false,
    this.isMythical = false,
    this.color = '',
    this.habitat,
    this.shape,
    this.eggGroups = const [],
  }) : isFav = MainApp.favoritePokemons.contains(name);

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null || json['url'] == null) {
      throw Exception('Datos inválidos para crear un Pokémon');
    }
    return Pokemon(name: json['name'], url: json['url']);
  }

  factory Pokemon.withDetails({
    required String name,
    required String url,
    required List<String> types,
    required String generation,
    required bool isLegendary,
    required bool isMythical,
    required String color,
    String? habitat,
    String? shape,
    required List<String> eggGroups,
  }) {
    return Pokemon(
      name: name,
      url: url,
      types: types,
      generation: generation,
      isLegendary: isLegendary,
      isMythical: isMythical,
      color: color,
      habitat: habitat,
      shape: shape,
      eggGroups: eggGroups,
    );
  }
  void changeFav() {
    checkFav();
    isFav = !isFav;
  }

  void checkFav() {
    isFav = MainApp.favoritePokemons.contains(
      name,
    ); //chequea que efectivamente isFav está marcado correctamente
  }
}
