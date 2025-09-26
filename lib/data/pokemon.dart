// === pokemon.dart ===
// Clase modelo para Pokémon: Almacena datos básicos.
// Simple data class; extensible.

class Pokemon {
  final String name;
  final String url;
  // Almacena el nombre del pokemon y su url.
  Pokemon({required this.name, required this.url});

  // Factory creada para recibir tanto el nombre como la url,con una verificacion de nulidad.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null || json['url'] == null) {
      throw Exception("Datos inválidos para crear un Pokémon");
    }
    return Pokemon(name: json['name'], url: json['url']);
  }
}
