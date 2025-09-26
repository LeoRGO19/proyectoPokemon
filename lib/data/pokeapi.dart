// === pokeapi.dart ===
// Servicio para trabajar con la API

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/data/pokemon.dart';

class PokeApi {
  // Metodo para mostrar pokemons en la lista principal.
  static Future<List<Pokemon>> fetchAllPokemon() async {
    final url = Uri.parse("https://pokeapi.co/api/v2/pokemon?limit=10000");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((json) => Pokemon.fromJson(json)).toList();
    } else {
      // Si no encuentra pokemon da error
      throw Exception("Error al cargar Pokémon");
    }
  }
}
