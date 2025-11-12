import 'package:flutter/material.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/data/exception_handler.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'package:http/http.dart' as http;

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

  int puntajePoke1 = 0;
  int puntajePoke2 = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fetchDetails(widget.pokemon1, widget.pokemon2); // Inicia fetch asíncrono.
  }

  int _getStat(Map<String, dynamic> details, String statName) {
    if (details.isEmpty || !details.containsKey('stats')) return 0;

    for (var statEntry in details['stats']) {
      if (statEntry['stat']['name'] == statName) {
        return statEntry['base_stat'];
      }
    }
    return 0; // Retorna 0 si no se encuentra
  }

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
        _types2 = detailedPokemon2.types;

        ganador();

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

  void ganador() {
    int statPoke1 = _getStat(_detailsPoke1, 'hp');
    int statPoke2 = _getStat(_detailsPoke2, 'hp');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
    } else {
      puntajePoke1++;
      puntajePoke2++;
    }

    statPoke1 = _getStat(_detailsPoke1, 'attack');
    statPoke2 = _getStat(_detailsPoke2, 'attack');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
    } else {
      puntajePoke1++;
      puntajePoke2++;
    }

    statPoke1 = _getStat(_detailsPoke1, 'defense');
    statPoke2 = _getStat(_detailsPoke2, 'defense');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
    } else {
      puntajePoke1++;
      puntajePoke2++;
    }

    statPoke1 = _getStat(_detailsPoke1, 'special-attack');
    statPoke2 = _getStat(_detailsPoke2, 'special-attack');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
    } else {
      puntajePoke1++;
      puntajePoke2++;
    }

    statPoke1 = _getStat(_detailsPoke1, 'special-defense');
    statPoke2 = _getStat(_detailsPoke2, 'special-defense');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
    } else {
      puntajePoke1++;
      puntajePoke2++;
    }

    statPoke1 = _getStat(_detailsPoke1, 'speed');
    statPoke2 = _getStat(_detailsPoke2, 'speed');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
    } else {
      puntajePoke1++;
      puntajePoke2++;
    }

    if (_weaknessesPoke1.isNotEmpty) {
      for (var debilidad in _weaknessesPoke1) {
        if (_types2.contains(debilidad)) puntajePoke1--;
      }
    }
    if (_weaknessesPoke2.isNotEmpty) {
      for (var debilidad in _weaknessesPoke2) {
        if (_types1.contains(debilidad)) puntajePoke2--;
      }
    }
  }

  Widget _buildWinnerImage() {
    final double availableHeight = 1000.0; // Valor de ejemplo

    if (puntajePoke1 > puntajePoke2) {
      final id1 = widget.pokemon1.url.split("/")[6];

      return Image.network(
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id1.png',
        width: MediaQuery.of(context).size.width * 0.4,
        height: availableHeight * 0.4,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    } else if (puntajePoke1 < puntajePoke2) {
      final id2 = widget.pokemon2.url.split("/")[6];

      return Image.network(
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id2.png',
        width: MediaQuery.of(context).size.width * 0.4,
        height: availableHeight * 0.4,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    } else {
      return const Text('¡Es un Empate!');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(/* ... */),
        body: Center(child: Text('Error al cargar datos: $_error')),
      );
    }
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
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ganador.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: 150, // Coordenada para la posición vertical
            left:
                MediaQuery.of(context).size.width *
                0.04, // Centra horizontalmente
            child: Center(
              child: _buildWinnerImage(), //Imagen del ganador
            ),
          ),
          Positioned(
            bottom: 350, // Coloca el texto en la parte inferior
            left: 0,
            right: MediaQuery.of(context).size.width * -0.5,
            child: Text(
              '¡El ganador es...!',
              textAlign: TextAlign.center,
              style: TextStyles.bodyText.copyWith(
                color: Colors.yellowAccent,
                fontSize: 50,
                shadows: [Shadow(blurRadius: 5.0, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
