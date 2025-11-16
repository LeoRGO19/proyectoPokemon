import 'package:flutter/material.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/data/exception_handler.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/screens/menu_principal.dart';
import 'package:pokedex/screens/selector_pokemon_screen.dart';

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

  final StringBuffer _bufferInformacion = StringBuffer();

  bool _isOverlayVisible = false;

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fetchDetails(widget.pokemon1, widget.pokemon2);
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

        ganador(poke1.name, poke2.name);

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

  void _textoInformativo(String texto) {
    _bufferInformacion.write(texto); // 'write' añade el texto
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void ganador(String poke1, String poke2) {
    int statPoke1 = _getStat(_detailsPoke1, 'hp');
    int statPoke2 = _getStat(_detailsPoke2, 'hp');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
      _textoInformativo("$poke1 tiene más vida que $poke2\n");
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
      _textoInformativo("$poke2 tiene más vida que $poke1\n");
    } else {
      puntajePoke1++;
      puntajePoke2++;
      _textoInformativo("Tienen misma cantidad de vida\n");
    }

    statPoke1 = _getStat(_detailsPoke1, 'attack');
    statPoke2 = _getStat(_detailsPoke2, 'attack');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
      _textoInformativo("$poke1 tiene más ataque que $poke2\n");
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
      _textoInformativo("$poke2 tiene más ataque que $poke1\n");
    } else {
      puntajePoke1++;
      puntajePoke2++;
      _textoInformativo("Tienen mismo poder de ataque\n");
    }

    statPoke1 = _getStat(_detailsPoke1, 'defense');
    statPoke2 = _getStat(_detailsPoke2, 'defense');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
      _textoInformativo("$poke1 tiene más defensa que $poke2\n");
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
      _textoInformativo("$poke2 tiene más defensa que $poke1\n");
    } else {
      puntajePoke1++;
      puntajePoke2++;
      _textoInformativo("Tienen misma cantidad de defensa\n");
    }

    statPoke1 = _getStat(_detailsPoke1, 'special-attack');
    statPoke2 = _getStat(_detailsPoke2, 'special-attack');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
      _textoInformativo("$poke1 tiene más ataque especial que $poke2\n");
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
      _textoInformativo("$poke2 tiene más ataque especial que $poke1\n");
    } else {
      puntajePoke1++;
      puntajePoke2++;
      _textoInformativo("Tienen mismo poder de ataque especial\n");
    }

    statPoke1 = _getStat(_detailsPoke1, 'special-defense');
    statPoke2 = _getStat(_detailsPoke2, 'special-defense');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
      _textoInformativo("$poke1 tiene más defensa especial que $poke2\n");
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
      _textoInformativo("$poke2 tiene más defensa especial que $poke1\n");
    } else {
      puntajePoke1++;
      puntajePoke2++;
      _textoInformativo("Tienen misma cantidad de defensa especial\n");
    }

    statPoke1 = _getStat(_detailsPoke1, 'speed');
    statPoke2 = _getStat(_detailsPoke2, 'speed');

    if (statPoke1 > statPoke2) {
      puntajePoke1++;
      _textoInformativo("$poke1 tiene más velocidad que $poke2\n");
    } else if (statPoke1 < statPoke2) {
      puntajePoke2++;
      _textoInformativo("$poke2 tiene más velocidad que $poke1\n");
    } else {
      puntajePoke1++;
      puntajePoke2++;
      _textoInformativo("Tienen misma velocidad\n");
    }

    int contador = 0;

    if (_weaknessesPoke1.isNotEmpty) {
      for (var debilidad in _weaknessesPoke1) {
        if (_types2.contains(debilidad)) {
          contador++;
          puntajePoke1--;
        }
      }
    }
    _textoInformativo(
      "$poke2 tiene $contador debilidades con respecto a $poke1\n",
    );

    if (_weaknessesPoke2.isNotEmpty) {
      for (var debilidad in _weaknessesPoke2) {
        contador = 0;
        if (_types1.contains(debilidad)) {
          contador++;
          puntajePoke2--;
        }
      }
    }
    _textoInformativo(
      "$poke1 tiene $contador debilidades con respecto a $poke2\n",
    );
  }

  Widget _buildWinnerImage() {
    if (puntajePoke1 > puntajePoke2) {
      final id1 = widget.pokemon1.url.split("/")[6];

      return Center(
        child: Image.network(
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id1.png',
          width: MediaQuery.of(context).size.width * 0.4,
          height: -5000,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      );
    } else if (puntajePoke1 < puntajePoke2) {
      final id2 = widget.pokemon2.url.split("/")[6];

      return Center(
        child: Image.network(
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id2.png',
          width: MediaQuery.of(context).size.width * 0.4,
          height: 400,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      );
    } else {
      return Positioned(
        top: MediaQuery.of(context).size.height * 0.5 - 100,
        left: MediaQuery.of(context).size.height * 0.5 - 200,
        right: MediaQuery.of(context).size.height * 0.5 - 100,

        child: Text(
          "¡Es un Empate!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            color: Colors.black,
            shadows: const [Shadow(blurRadius: 5.0, color: Colors.white)],
          ),
        ),
      );
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MenuPrincipal()),
                (Route<dynamic> route) => false,
              );
            },
            tooltip: 'Volver a Menú Principal',
          ),
          SizedBox(width: 50),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ganador.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 250,
            left: -700,
            right: 0,
            child: _buildWinnerImage(), //Imagen del ganador
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.5 - 100,
            left: 0,
            right: MediaQuery.of(context).size.width * -0.5,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '¡El ganador es...!',
                    textAlign: TextAlign.center,
                    style: TextStyles.bodyText.copyWith(
                      color: Colors.yellowAccent,
                      fontSize: 50,
                      shadows: const [
                        Shadow(blurRadius: 5.0, color: Colors.black),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectorPokemonScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Comparar nuevamente",
                      style: TextStyles.menuText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isOverlayVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleOverlay,
                child: Container(
                  color: Colors.black54.withOpacity(0.7),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
                        ),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 15.0),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Detalles de la Comparación',
                              style: TextStyles.bodyText.copyWith(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.backgroundComponentSelected,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Divider(color: Colors.grey),

                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  _bufferInformacion.toString(),
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleOverlay,
        backgroundColor: AppColors.backgroundComponentSelected,
        child: Icon(
          _isOverlayVisible ? Icons.close : Icons.info_outline,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.white,
    );
  }
}
