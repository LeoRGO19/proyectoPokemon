import 'package:flutter/material.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/data/exception_handler.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/components/characteristic_widget.dart';
import 'package:pokedex/components/pokedex_components/stats_chart_widget.dart';

class ResultadoComparar extends StatefulWidget {
  final Pokemon pokemon1;
  final Pokemon pokemon2;

  const ResultadoComparar({
    super.key,
    required this.pokemon1,
    required this.pokemon2,
  });

  @override
  State<ResultadoComparar> createState() => _ResultadoCompararState();
}

class _ResultadoCompararState extends State<ResultadoComparar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Map<String, dynamic> _detailsPoke1 = {}; // Detalles completos de Pokémon.
  Map<String, dynamic> _detailsPoke2 = {};

  List<String> _weaknessesPoke1 = []; // Debilidades basadas en tipos.
  List<String> _weaknessesPoke2 = [];

  List<String> _types1 = []; // Tipos.
  List<String> _types2 = []; // Tipos.

  bool _isLoading = true; // Flag de carga.
  String _error = ''; // Mensaje de error.

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fetchDetails(widget.pokemon1, widget.pokemon2); // Inicia fetch asíncrono.
  }

  static const Map<String, String> traduccionesTipo = {
    'grass': 'Planta',
    'fire': 'Fuego',
    'water': 'Agua',
    'electric': 'Eléctrico',
    'ice': 'Hielo',
    'fighting': 'Lucha',
    'poison': 'Veneno',
    'ground': 'Tierra',
    'flying': 'Volador',
    'psychic': 'Psíquico',
    'bug': 'Bicho',
    'rock': 'Roca',
    'ghost': 'Fantasma',
    'dragon': 'Dragón',
    'dark': 'Siniestro',
    'steel': 'Acero',
    'fairy': 'Hada',
    'normal': 'Normal',
  };
  Future<void> _fetchDetails(Pokemon poke1, Pokemon poke2) async {
    // Función para fetch todos los datos.
    try {
      // Try-catch para errores.
      final details1 = await PokeApi.fetchPokemonFullDetails(
        poke1.url,
      ); // Fetch detalles full.
      final details2 = await PokeApi.fetchPokemonFullDetails(poke2.url);

      final detailedPokemon1 = await PokeApi.fetchPokemonDetails(
        // Fetch detalles extendidos.
        poke1,
        http.Client(),
      );

      final detailedPokemon2 = await PokeApi.fetchPokemonDetails(
        // Fetch detalles extendidos.
        poke2,
        http.Client(),
      );

      final weaknesses1 = await PokeApi.fetchWeaknesses(
        detailedPokemon1.types,
      ); // Debilidades.

      final weaknesses2 = await PokeApi.fetchWeaknesses(detailedPokemon2.types);

      if (!mounted) return; //chequea que sea visible, si no sale

      setState(() {
        // Actualiza estado.
        _detailsPoke1 = details1; // Asigna detalles.
        _detailsPoke2 = details2;
        _weaknessesPoke1 = weaknesses1; // Debilidades.
        _weaknessesPoke2 = weaknesses2;

        _types1 = detailedPokemon1.types; // Tipos.
        _types2 = detailedPokemon2.types; // Tipos.

        _isLoading = false; // Fin de carga.
      });
    } catch (e) {
      if (!mounted) return; //chequea que sea visible, si no sale

      final String handledError = ExceptionHandler.handle(e);
      // Catch error.
      setState(() {
        // Actualiza con error.
        _error = handledError; // Mensaje.
        _isLoading = false; // Fin carga.
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void ganador() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resultados de la PokeComparación',
          style: TextStyles.bodyText,
        ),
        backgroundColor: AppColors.backgroundComponentSelected,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Expanded(
        // Expande.
        child: Column(
          // Columna para título y chart.
          mainAxisAlignment: MainAxisAlignment.start, // Arriba.
          children: [
            Padding(
              // Padding título.
              padding: const EdgeInsets.all(8.0), // All.
              child: Text(
                'Estadísticas de Poder',
                style: TextStyles.bodyText, // Estilo.
              ),
            ),
            StatsChartWidget(stats: _detailsPoke1['stats']),
            StatsChartWidget(stats: _detailsPoke2['stats']),
            CharacteristicWidget(
              title: 'Debilidades Pokemon 1:',
              value: _weaknessesPoke1.isNotEmpty
                  //? _weaknesses.join(', ').toUpperCase()
                  ? _weaknessesPoke1
                        .map(
                          (t) =>
                              traduccionesTipo[t.toLowerCase()] ??
                              t, //traduce debilidades
                        )
                        .join(', ')
                        .toUpperCase()
                  : 'No disponible',
              backgroundColor: AppColors.secondary,
            ), // Widget extraído.

            CharacteristicWidget(
              title: 'Debilidades Pokemon 2:',
              value: _weaknessesPoke2.isNotEmpty
                  //? _weaknesses.join(', ').toUpperCase()
                  ? _weaknessesPoke2
                        .map(
                          (t) =>
                              traduccionesTipo[t.toLowerCase()] ??
                              t, //traduce debilidades
                        )
                        .join(', ')
                        .toUpperCase()
                  : 'No disponible',
              backgroundColor: AppColors.secondary,
            ), // Widget extraído.
          ],
        ),
      ),
    );
  }
}
