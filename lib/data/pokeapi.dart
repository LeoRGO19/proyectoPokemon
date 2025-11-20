import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/data/pokemon.dart';

class PokeApi {
  static const Duration _timeoutDuration = Duration(seconds: 30);

  static Future<List<Pokemon>> fetchBatchWithDetails({
    required int limit,
    required int offset,
  }) async {
    final url = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset',
    );
    final client = http.Client();

    try {
      final response = await client.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'];
        final basicPokemons = results
            .map((json) => Pokemon.fromJson(json)) // Mapea a basic.
            .toList();

        // Obtener detalles de cada Pokémon en paralelo (aquí ocurre el riesgo de fallo de Hypno)
        final detailedPokemons = await Future.wait(
          // Paraleliza details.
          basicPokemons.map((p) => fetchPokemonDetails(p, client)).toList(),
        );

        return detailedPokemons;
      } else {
        throw Exception(
          'Error al cargar lista de Pokémon con detalles: ${response.statusCode}',
        );
      }
    } finally {
      client.close(); // Asegura que el cliente se cierre
    }
  }

  static Future<Pokemon> fetchPokemonDetails(
    // Fetch details extendidos.
    Pokemon basicPokemon,
    http.Client client, // Client reutilizable.
  ) async {
    final pokemonUrl = Uri.parse(basicPokemon.url);
    final pokemonResponse = await client
        .get(pokemonUrl)
        .timeout(_timeoutDuration);

    if (pokemonResponse.statusCode != 200) {
      // No OK.
      throw Exception(
        'Error al cargar detalles de ${basicPokemon.name}',
      ); // Throw.
    }

    final pokemonData = jsonDecode(pokemonResponse.body);
    final speciesUrl = Uri.parse(pokemonData['species']['url']);
    final speciesResponse = await client
        .get(speciesUrl)
        .timeout(_timeoutDuration);

    if (speciesResponse.statusCode != 200) {
      throw Exception('Error al cargar especie de ${basicPokemon.name}');
    }

    final speciesData = jsonDecode(speciesResponse.body);
    final List<String> types = (pokemonData['types'] as List)
        .map((t) => t['type']['name'].toString().toLowerCase())
        .toList();

    final color = speciesData['color']['name'].toLowerCase();
    final habitat = speciesData['habitat'] != null
        ? speciesData['habitat']['name'].toLowerCase()
        : null;
    final shape = speciesData['shape'] != null
        ? speciesData['shape']['name'].toLowerCase()
        : null;
    final eggGroups = (speciesData['egg_groups'] as List)
        .map((eg) => eg['name'].toString().toLowerCase())
        .toList();

    return Pokemon.withDetails(
      name: basicPokemon.name,
      url: basicPokemon.url,
      types: types,
      generation: speciesData['generation']['name'].toLowerCase(),
      isLegendary: speciesData['is_legendary'],
      isMythical: speciesData['is_mythical'],
      color: color,
      habitat: habitat,
      shape: shape,
      eggGroups: eggGroups,
    );
  }

  static Future<Pokemon?> fetchPokemonByName(String name) async {
    // Por name.
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');
    final client = http.Client();
    try {
      final response = await client.get(url).timeout(_timeoutDuration);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final basicPokemon = Pokemon.fromJson({
          'name': data['name'],
          'url': url.toString(),
        });
        final result = await fetchPokemonDetails(basicPokemon, client);
        client.close();
        return result;
      } else {
        client.close();
        return null;
      }
    } catch (e) {
      client.close();
      return null;
    }
  }

  static Future<Map<String, dynamic>> fetchPokemonFullDetails(
    // Full details.
    String url,
  ) async {
    final client = http.Client(); // Client.
    final response = await client
        .get(Uri.parse(url))
        .timeout(_timeoutDuration); // Get.
    if (response.statusCode == 200) {
      // OK.
      final result = jsonDecode(response.body); // Decode.
      client.close(); // Cierra.
      return result; // Retorna.
    } else {
      client.close(); // Cierra.
      throw Exception(
        // Throw.
        'Error al cargar detalles completos: ${response.statusCode}',
      );
    }
  }

  static Future<Map<String, dynamic>> fetchPokemonSpecies(
    // Species.
    String speciesUrl,
  ) async {
    final client = http.Client();
    final response = await client
        .get(Uri.parse(speciesUrl))
        .timeout(_timeoutDuration);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      client.close();
      return result;
    } else {
      client.close();
      throw Exception(
        'Error al cargar datos de especie: ${response.statusCode}',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> fetchEvolutionChain(
    // Chain.
    String speciesUrl,
  ) async {
    final client = http.Client();
    final speciesResponse = await client
        .get(Uri.parse(speciesUrl))
        .timeout(_timeoutDuration);
    if (speciesResponse.statusCode != 200) {
      client.close();
      throw Exception('Error al cargar especie para evolución');
    }
    final speciesData = jsonDecode(speciesResponse.body);
    final evolutionChainUrl = speciesData['evolution_chain']['url'];

    final evolutionResponse = await client
        .get(Uri.parse(evolutionChainUrl))
        .timeout(_timeoutDuration);
    if (evolutionResponse.statusCode == 200) {
      final data = jsonDecode(evolutionResponse.body);
      final List<Map<String, dynamic>> evolutions = [];
      _parseEvolutionChain(
        data['chain'],
        evolutions,
      ); // recorre recursivamente cada Pokémon y lo va agregando a la lista evolutions
      client.close();
      return evolutions;
    } else {
      client.close();
      throw Exception('Error al cargar cadena de evolución');
    }
  }

  //Esta función recorre recursivamente la estructura en forma de árbol que devuelve la PokeAPI.
  static void _parseEvolutionChain(
    Map<String, dynamic> chain,
    List<Map<String, dynamic>> evolutions,
  ) {
    final speciesName = chain['species']['name']; //nombre del Pokémon.
    final speciesUrl = chain['species']['url'].replaceAll(
      //URL original apunta a species, pero se reemplaza "pokemon-species/" por "pokemon/" para apuntar directamente al recurso del Pokémon.
      'pokemon-species/',
      'pokemon/',
    );
    evolutions.add({'name': speciesName, 'url': speciesUrl});
    for (var evolution in chain['evolves_to'] as List) {
      //evolves_to es una lista de evoluciones siguientes.
      _parseEvolutionChain(
        evolution,
        evolutions,
      ); //Si un Pokémon puede evolucionar a varios, se recorre cada uno.
    }
  }

  static Future<String> fetchDescription(String speciesUrl) async {
    // Descripción.
    final client = http.Client();
    final response = await client
        .get(Uri.parse(speciesUrl))
        .timeout(_timeoutDuration);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final flavorTexts = data['flavor_text_entries'] as List;
      for (var entry in flavorTexts) {
        if (entry['language']['name'] == 'es') {
          client.close();
          return entry['flavor_text'].replaceAll('\n', ' ');
        }
      }
      for (var entry in flavorTexts) {
        if (entry['language']['name'] == 'en') {
          client.close();
          return entry['flavor_text'].replaceAll('\n', ' ');
        }
      }
      client.close();
      return 'Descripción no disponible';
    } else {
      client.close();
      throw Exception('Error al cargar descripción');
    }
  }

  static Future<List<String>> fetchWeaknesses(List<String> types) async {
    // Debilidades.
    final client = http.Client();
    Set<String> weaknesses = {};
    for (var type in types) {
      final url = Uri.parse('https://pokeapi.co/api/v2/type/$type');
      final response = await client.get(url).timeout(_timeoutDuration);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final damageRelations =
            data['damage_relations']['double_damage_from'] as List;
        for (var rel in damageRelations) {
          weaknesses.add(rel['name']);
        }
      }
    }
    client.close();
    return weaknesses.toList();
  }
}
