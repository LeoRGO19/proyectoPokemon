import 'dart:convert';

// Clase modelo para Pokémon.
// Representa data básica y extendida.
// Funciona con factories para fromJson y withDetails.
// Objetivo: Almacenar data fetched para UI y filtros.

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
  });

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

  //transforma pokemon a json para guardar en base de datos
  Map<String, dynamic> toMap() => {
    'name': name,
    'url': url,
    'types': jsonEncode(types),
    'generation': generation,
    'isLegendary': isLegendary
        ? 1
        : 0, //como la base de datos no guarda bool lo pasamos int
    'isMythical': isMythical ? 1 : 0,
    'color': color,
    'shape': shape ?? '',
    'habitat': habitat ?? '',
    'eggGroups': jsonEncode(eggGroups),
  };

  //construye el pokemon a partir de la base de datos
  factory Pokemon.fromMap(Map<String, dynamic> map) {
    //pasa de int a bool
    bool a = false;
    bool b = false;
    if (map["isLegendary"] == '1') a = true;
    if (map["isMythical"] == '1') b = true;
    return Pokemon(
      name: map["name"],
      url: map["url"],
      types: List<String>.from(jsonDecode(map['types'])),
      generation: map["generation"],
      isLegendary: a,
      isMythical: b,
      color: map["color"],
      habitat: map["habitat"],
      shape: map["shape"],
      eggGroups: List<String>.from(jsonDecode(map['eggGroups'])),
    );
  }
}
