import 'package:pokedex/data/pokemon.dart';

// === ListaPrueba.dart ===
// Clase de datos de prueba: Lista estática de Pokémon.
// Simula datos; temporal.
// Para PokeAPI: Eliminar esta clase; usar servicio o repository para fetch real.
class ListaPrueba {
  final List<Pokemon> pokemonList = [
    Pokemon(
      id: 1,
      name: 'Bulbasaur',
      height: 7,
      weight: 69,
      imagePath: 'assets/images/pokemonejm.png',
    ),
    Pokemon(
      id: 4,
      name: 'Charmander',
      height: 6,
      weight: 85,
      imagePath: 'assets/images/pokemonejm.png',
    ),
    Pokemon(
      id: 7,
      name: 'Squirtle',
      height: 5,
      weight: 90,
      imagePath: 'assets/images/pokemonejm.png',
    ),
    Pokemon(
      id: 7,
      name: 'Otro',
      height: 5,
      weight: 90,
      imagePath: 'assets/images/pokemonejm.png',
    ),
    Pokemon(
      id: 7,
      name: 'Otro2',
      height: 5,
      weight: 90,
      imagePath: 'assets/images/pokemonejm.png',
    ),
    Pokemon(
      id: 7,
      name: 'otro3',
      height: 5,
      weight: 90,
      imagePath: 'assets/images/pokemonejm.png',
    ),
  ];
  // Cambio con API: En lugar de esto, un método async List<Pokemon> fetchPokemons() { /* http.get PokeAPI */ }.
  // Faltante: Manejo de errores en fetch, paginación (offset/limit en PokeAPI).
}
