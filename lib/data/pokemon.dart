// === Pokemon.dart ===
// Clase modelo para Pokémon: Almacena datos básicos.
// Simple data class; extensible.
// Para PokeAPI: Agregar más campos como List<String> types, String generation, String? spriteUrl, etc.

class Pokemon {
  final int id;
  final String name;
  final int height; // En decímetros
  final int weight; // En hectogramos
  final String imagePath; // Ruta de la imagen local

  Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.imagePath,
  });
  // Faltante: Factory fromJson para parsear de PokeAPI (ej: Pokemon.fromJson(Map<String, dynamic> json)).
}
