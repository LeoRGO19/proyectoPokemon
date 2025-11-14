import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/components/team_components/team.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/data/pokeapi.dart';
//import 'package:pokedex/exceptions/exceptions.dart';
import 'package:pokedex/screens/menu_principal.dart';
import 'package:pokedex/components/characteristic_widget.dart';
import 'package:pokedex/components/pokedex_components/stats_chart_widget.dart';
import 'package:pokedex/screens/imc_pokemon_details.dart';

//boton que permite agregar pokemon a equipo
class TeamStats extends StatefulWidget {
  final Team team;
  const TeamStats({super.key, required this.team});
  @override
  State<TeamStats> createState() => _TeamStatsState(); // Crea estado.
}

class _TeamStatsState extends State<TeamStats> {
  List<Pokemon> pokemons = []; // Lista de evoluciones.
  List<String> _weaknesses = []; // Debilidades basadas en tipos.
  List<String> _types = []; // Tipos.
  List<String> _major = [];
  List<String> _inmunity = [];
  List<String> _attacks = [];
  bool _isLoading = true; // Flag de carga.
  String _error = ''; // Mensaje de error.
  //mapa con traducciones de tipo para utilizar al mostrarlas en la descripción del pokémon
  // hacemos esto de forma manual en vez de pedir este dato ya traducido desde la opkeapi porque eso consume AÚN más recursos
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

  final Map<String, Map<String, double>> matrix_of_weakness = {
    'grass': {
      'grass': 0.5,
      'fire': 2,
      'water': 0.5,
      'electric': 0.5,
      'ice': 2,
      'poison': 2,
      'ground': 0.5,
      'flying': 2,
      'bug': 2,
    },
    'fire': {
      'grass': 0.5,
      'fire': 0.5,
      'water': 2,
      'ice': 0.5,
      'ground': 2,
      'bug': 0.5,
      'rock': 2,
      'steel': 0.5,
      'fairy': 0.5,
    },
    'water': {
      'grass': 2,
      'fire': 0.5,
      'water': 0.5,
      'electric': 2,
      'ice': 0.5,
      'steel': 0.5,
    },
    'electric': {'electric': 0.5, 'ground': 2, 'flying': 0.5, 'steel': 0.5},
    'ice': {'fire': 2, 'ice': 0.5, 'fighting': 2, 'rock': 2, 'steel': 2},
    'fighting': {
      'flying': 2,
      'psychic': 2,
      'bug': 0.5,
      'rock': 0.5,
      'dark': 0.5,
      'fairy': 2,
    },
    'poison': {
      'grass': 0.5,
      'fighting': 0.5,
      'poison': 0.5,
      'ground': 2,
      'psychic': 2,
      'bug': 0.5,
      'fairy': 0.5,
    },
    'ground': {
      'grass': 2,
      'water': 2,
      'electric': 0.0,
      'ice': 2,
      'poison': 0.5,
      'rock': 0.5,
    },
    'flying': {
      'grass': 0.5,
      'electric': 2,
      'ice': 2,
      'fighting': 0.5,
      'ground': 0.0,
      'bug': 0.5,
      'rock': 2,
    },
    'psychic': {
      'fighting': 0.5,
      'psychic': 0.5,
      'bug': 2,
      'ghost': 2,
      'dark': 2,
    },
    'bug': {
      'grass': 0.5,
      'fire': 2,
      'fighting': 0.5,
      'ground': 0.5,
      'flying': 2,
      'rock': 2,
    },
    'rock': {
      'grass': 2,
      'fire': 0.5,
      'water': 2,
      'fighting': 2,
      'poison': 0.5,
      'ground': 2,
      'flying': 0.5,
      'steel': 2,
      'normal': 0.5,
    },
    'ghost': {
      'fighting': 0.0,
      'poison': 0.5,
      'bug': 0.5,
      'ghost': 2,
      'dark': 2,
      'normal': 0.0,
    },
    'dragon': {
      'grass': 0.5,
      'fire': 0.5,
      'water': 0.5,
      'electric': 0.5,
      'ice': 2,
      'dragon': 2,
      'fairy': 2,
    },
    'dark': {
      'fighting': 2,
      'psychic': 0.0,
      'bug': 2,
      'ghost': 0.5,
      'dark': 0.5,
      'fairy': 2,
    },
    'steel': {
      'grass': 0.5,
      'fire': 2,
      'ice': 0.5,
      'fighting': 2,
      'poison': 0.0,
      'ground': 2,
      'flying': 0.5,
      'psychic': 0.5,
      'bug': 0.5,
      'rock': 0.5,
      'dragon': 0.5,
      'steel': 0.5,
      'fairy': 0.5,
      'normal': 0.5,
    },
    'fairy': {
      'fighting': 0.5,
      'poison': 2,
      'bug': 0.5,
      'dragon': 0.0,
      'dark': 0.5,
      'steel': 2,
    },
    'normal': {'fighting': 2, 'ghost': 0},
  };

  final Map<String, Map<String, double>> attack_matrix = {
    'grass': {
      'grass': 0.5,
      'fire': 0.5,
      'water': 2,
      'ground': 2,
      'rock': 2,
      'dragon': 0.5,
      'steel': 0.5,
      'poison': 0.5,
      'flying': 0.5,
      'bug': 0.5,
    },

    'fire': {
      'grass': 2,
      'fire': 0.5,
      'water': 0.5,
      'ice': 2,
      'bug': 2,
      'rock': 0.5,
      'dragon': 0.5,
      'steel': 2,
    },

    'water': {
      'fire': 2,
      'water': 0.5,
      'grass': 0.5,
      'ground': 2,
      'rock': 2,
      'dragon': 0.5,
    },

    'electric': {
      'water': 2,
      'electric': 0.5,
      'grass': 0.5,
      'ground': 0.0,
      'flying': 2,
      'dragon': 0.5,
    },

    'ice': {
      'grass': 2,
      'ground': 2,
      'flying': 2,
      'dragon': 2,
      'fire': 0.5,
      'water': 0.5,
      'ice': 0.5,
      'steel': 0.5,
    },

    'fighting': {
      'normal': 2,
      'ice': 2,
      'rock': 2,
      'dark': 2,
      'steel': 2,
      'poison': 0.5,
      'flying': 0.5,
      'psychic': 0.5,
      'bug': 0.5,
      'fairy': 0.5,
      'ghost': 0.0,
    },

    'poison': {
      'grass': 2,
      'fairy': 2,
      'poison': 0.5,
      'ground': 0.5,
      'rock': 0.5,
      'ghost': 0.5,
      'steel': 0.0,
    },

    'ground': {
      'fire': 2,
      'electric': 2,
      'poison': 2,
      'rock': 2,
      'steel': 2,
      'grass': 0.5,
      'bug': 0.5,
      'flying': 0.0,
    },

    'flying': {
      'grass': 2,
      'fighting': 2,
      'bug': 2,
      'electric': 0.5,
      'rock': 0.5,
      'steel': 0.5,
    },

    'psychic': {
      'fighting': 2,
      'poison': 2,
      'psychic': 0.5,
      'steel': 0.5,
      'dark': 0.0,
    },

    'bug': {
      'grass': 2,
      'psychic': 2,
      'dark': 2,
      'fire': 0.5,
      'fighting': 0.5,
      'poison': 0.5,
      'flying': 0.5,
      'ghost': 0.5,
      'steel': 0.5,
      'fairy': 0.5,
    },

    'rock': {
      'fire': 2,
      'ice': 2,
      'flying': 2,
      'bug': 2,
      'fighting': 0.5,
      'ground': 0.5,
      'steel': 0.5,
    },

    'ghost': {'psychic': 2, 'ghost': 2, 'dark': 0.5, 'normal': 0.0},

    'dragon': {'dragon': 2, 'steel': 0.5, 'fairy': 0.0},

    'dark': {
      'psychic': 2,
      'ghost': 2,
      'fighting': 0.5,
      'dark': 0.5,
      'fairy': 0.5,
    },

    'steel': {
      'ice': 2,
      'rock': 2,
      'fairy': 2,
      'fire': 0.5,
      'water': 0.5,
      'electric': 0.5,
      'steel': 0.5,
    },

    'fairy': {
      'fighting': 2,
      'dragon': 2,
      'dark': 2,
      'fire': 0.5,
      'poison': 0.5,
      'steel': 0.5,
    },

    'normal': {'rock': 0.5, 'steel': 0.5, 'ghost': 0.0},
  };

  final ScrollController _scrollController =
      ScrollController(); // Controller para scroll en derecha.

  @override
  void dispose() {
    // Limpia recursos.
    _scrollController.dispose(); // Libera controller.
    super.dispose(); // Super dispose.
  }

  @override
  void initState() {
    // Inicializa estado.
    super.initState(); // Llama super.
    _fetchDetails(); // Inicia fetch asíncrono.
  }

  Future<void> _fetchDetails() async {
    // Función para fetch todos los datos.
    final getWeak = await getWeakessesInCommon();

    setState(() {
      // Actualiza estado.
      _weaknesses = getWeak; // Debilidades en comun
      _types = getTypesInCommon(); //tipos en comun
      _major = getDebilitatingWeaknesses(); //debilidades fuertes
      _inmunity =
          getParcialInmunity(); //inmunidades compartidas por más de la mitad del equipo
      _attacks = getStrongerAttacks(); //ataques son mas fuertes en esos tipos
      _isLoading = false; // Fin de carga.
    });
  }

  @override
  Widget build(BuildContext context) {
    pokemons = widget.team.pokemons;
    // Construye UI.
    return Scaffold(
      // Scaffold base.
      backgroundColor: const Color.fromARGB(255, 23, 32, 32), // Fondo oscuro.
      appBar: AppBarForMenuButton(context),
      body:
          _isLoading // Condicional para loading.
          ? const Center(child: CircularProgressIndicator()) // Indicator.
          : _error
                .isNotEmpty // Si error.
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error,
                    style: TextStyles.errorText,
                    textAlign: TextAlign.center,
                  ), // Mensaje error.
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text("Volver al Menú Principal"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Blanco.
                      foregroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuPrincipal(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              // Builder para constraints responsive.
              builder: (context, constraints) {
                // Builder function.
                final screenHeight = MediaQuery.of(
                  context,
                ).size.height; // Altura pantalla.
                final titleHeight = screenHeight * 0.15; // Altura título.
                final availableHeight = // Altura disponible.
                    screenHeight -
                    titleHeight -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight;

                return Column(
                  // Columna principal.
                  children: [
                    Container(
                      // Contenedor título.
                      height: titleHeight, // Altura calculada.
                      width: double.infinity, // Ancho full.
                      color: AppColors.fontoTituloDetalle, // Negro.
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // Centra texto.
                              children: [
                                Text(
                                  // Nombre del equipo
                                  widget.team.title,
                                  style: TextStyles.bodyText.copyWith(
                                    // Estilo con color blanco y size 24.
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      // Expande el row principal.
                      child: Row(
                        // Row para columnas izquierda/derecha.
                        children: [
                          // Columna izquierda: 50% ancho
                          SizedBox(
                            // SizedBox para ancho fijo.
                            width:
                                MediaQuery.of(context).size.width * 0.5, // 50%.
                            child: Column(
                              // Columna para bloques superior/inferior.
                              children: [
                                // Bloque superior: GIF y estadísticas (60% de la altura disponible)
                                Padding(
                                  // Padding alrededor.
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 6.0,
                                    top: 10.0,
                                    bottom: 6.0,
                                  ), // Espacios.
                                  child: Container(
                                    // Contenedor blanco.
                                    height:
                                        availableHeight * 0.60, // 60% altura.
                                    color: Colors.white, // Blanco.
                                    child: Row(
                                      // Row para stats e imagen.
                                      children: [
                                        // Estadísticas (50% del ancho de la columna izquierda)
                                        stats(),
                                        SizedBox(
                                          height: availableHeight * 0.60,
                                          width: 100,
                                          child: Text(''),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Bloque inferior: Evoluciones (35% de la altura disponible)
                                Padding(
                                  // Padding alrededor.
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 6.0,
                                    top: 6.0,
                                    bottom: 10.0,
                                  ), // Espacios.
                                  child: Container(
                                    // Contenedor blanco.
                                    height:
                                        availableHeight *
                                        0.30, // 30% altura (nota: original 0.30, pero sumaba a 0.90, falta 0.10?).
                                    color: Colors.white,
                                    child: Column(
                                      // Columna para título y list.
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Izquierda.
                                      children: [
                                        const Padding(
                                          // Padding título.
                                          padding: EdgeInsets.all(8.0), // All.
                                          child: Text(
                                            'Miembros del equipo:',
                                            style: TextStyles.bodyText,
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: pokemons.length,
                                            itemBuilder: (context, index) {
                                              final poke = pokemons[index];
                                              final id =
                                                  widget.team.details[poke
                                                      .name]?['id']; //evitamos que hayan errores si id aún no carga
                                              if (id == null) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                child: Card(
                                                  child: InkWell(
                                                    onTap: () async {
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PokemonDetailScreen(
                                                                pokemon: poke,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center, // Centro.
                                                      children: [
                                                        Image.network(
                                                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
                                                          width:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.1,
                                                          height:
                                                              availableHeight *
                                                              0.1, // Altura.
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) => const Icon(
                                                                Icons.error,
                                                              ), // Error icon.
                                                        ),
                                                        Text(
                                                          poke.name
                                                              .toUpperCase(), // Nombre upper.
                                                          style: TextStyles
                                                              .cardText,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          characteristics(context.watch<TeamsProvider>()),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Expanded characteristics(TeamsProvider teams) {
    return Expanded(
      // Expande.
      child: Padding(
        // Padding alrededor.
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 10.0,
          top: 10.0,
          bottom: 10.0,
        ), // Espacios.
        child: RawScrollbar(
          // Scrollbar raw.
          controller: _scrollController, // Controller.
          thumbVisibility: true, // Visible.
          thickness: 8, // Grosor.
          radius: Radius.circular(4), // Radio.
          thumbColor: Color.fromARGB(
            1,
            29,
            40,
            46,
          ), // Color (casi transparente?).
          child: SingleChildScrollView(
            // Scroll view single.
            controller: _scrollController, // Controller.
            child: Container(
              // Contenedor blanco.
              color: const Color.fromARGB(255, 255, 255, 255), // Blanco.
              padding: const EdgeInsets.all(16.0), // Padding.
              child: Column(
                // Columna de características.
                crossAxisAlignment: CrossAxisAlignment.start, // Izquierda.
                children: [
                  CharacteristicWidget(
                    title: 'Tipos más comunes:',
                    value: _types.isNotEmpty
                        //? _types.join(', ').toUpperCase()
                        ? _types
                              .map(
                                (t) =>
                                    traduccionesTipo[t.toLowerCase()] ??
                                    t, //traduce los tipos
                              )
                              .join(', ')
                              .toUpperCase()
                        : 'No hay tipos compartidos por al menos la mitad del equipo',
                    backgroundColor: AppColors.primary,
                  ),
                  CharacteristicWidget(
                    title: 'Debilidades más comunes:',
                    value: _weaknesses.isNotEmpty
                        ? _weaknesses
                              .map(
                                (t) =>
                                    traduccionesTipo[t.toLowerCase()] ??
                                    t, //traduce debilidades
                              )
                              .join(', ')
                              .toUpperCase()
                        : 'No hay debilidades compartidas por al menos la mitad del equipo',
                    backgroundColor: AppColors.secondary,
                  ),
                  CharacteristicWidget(
                    title: 'Debilidades importantes:',
                    value: _major.isNotEmpty
                        //? _types.join(', ').toUpperCase()
                        ? _major
                              .map(
                                (t) =>
                                    traduccionesTipo[t.toLowerCase()] ??
                                    t, //traduce los tipos
                              )
                              .join(', ')
                              .toUpperCase()
                        : 'No hay debilidades importantes (ataque x2) compartidos por al menos la mitad del equipo',
                    backgroundColor: AppColors.primary,
                  ),
                  CharacteristicWidget(
                    title: 'Inmunidades importantes:',
                    value: _inmunity.isNotEmpty
                        ? _inmunity
                              .map(
                                (t) =>
                                    traduccionesTipo[t.toLowerCase()] ??
                                    t, //traduce los tipos
                              )
                              .join(', ')
                              .toUpperCase()
                        : 'No hay inmunidades compartidos por al menos la mitad del equipo',
                    backgroundColor: AppColors.primary,
                  ),
                  CharacteristicWidget(
                    title: 'Equipo es más dañino contra:',
                    value: _attacks.isNotEmpty
                        ? _attacks
                              .map(
                                (t) =>
                                    traduccionesTipo[t.toLowerCase()] ??
                                    t, //traduce los tipos
                              )
                              .join(', ')
                              .toUpperCase()
                        : 'No hay tipos contra los que al menos la mitad del equipo hace más daño',
                    backgroundColor: AppColors.primary,
                  ),
                  Visibility(
                    visible: widget.team.notes != '',
                    child: InkWell(
                      onTap: () {
                        teams.editNotes(context, widget.team);
                      },
                      child: CharacteristicWidget(
                        title: 'Notas sobre el equipo:',
                        value: widget.team.notes,
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded stats() {
    return Expanded(
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
          StatsChartWidget(
            stats: calculateStats(),
            isTeam: true,
          ), // Widget extraído.
        ],
      ),
    );
  }

  List<int> calculateStats() {
    pokemons = widget.team.pokemons;
    int total = pokemons.length;
    int hp = 0;
    int atk = 0;
    int df = 0;
    int satk = 0;
    int sdf = 0;
    int spd = 0;
    for (Pokemon poke in pokemons) {
      List<dynamic> stats = widget.team.details[poke.name]?['stats'];
      List<int> statValues = (stats).map((s) => s['base_stat'] as int).toList();
      hp += statValues[0];
      atk += statValues[1];
      df += statValues[2];
      satk += statValues[3];
      sdf += statValues[4];
      spd += statValues[5];
    }
    return [
      hp ~/ total,
      atk ~/ total,
      df ~/ total,
      satk ~/ total,
      sdf ~/ total,
      spd ~/ total,
    ];
  }

  Future<List<String>> getWeakessesInCommon() async {
    final List<String> common = [];
    Map<String, int> weak = {
      'grass': 0,
      'fire': 0,
      'water': 0,
      'electric': 0,
      'ice': 0,
      'fighting': 0,
      'poison': 0,
      'ground': 0,
      'flying': 0,
      'psychic': 0,
      'bug': 0,
      'rock': 0,
      'ghost': 0,
      'dragon': 0,
      'dark': 0,
      'steel': 0,
      'fairy': 0,
      'normal': 0,
    };
    pokemons = widget.team.pokemons;
    int min = (pokemons.length == 2)
        ? 2
        : (pokemons.length ~/ 2 + pokemons.length % 2);
    for (Pokemon poke in pokemons) {
      final weaknesses = await PokeApi.fetchWeaknesses(
        poke.types,
      ); // Debilidades.
      weak.forEach((key, value) {
        if (weaknesses.contains(key)) {
          setState(() {
            weak.update(key, (value) => value + 1);
          });
        }
      });
    }
    weak.forEach((key, value) {
      if (value >= min) {
        common.add(key);
      }
    });
    return common;
  }

  List<String> getTypesInCommon() {
    final List<String> common = [];
    Map<String, int> types = {
      'grass': 0,
      'fire': 0,
      'water': 0,
      'electric': 0,
      'ice': 0,
      'fighting': 0,
      'poison': 0,
      'ground': 0,
      'flying': 0,
      'psychic': 0,
      'bug': 0,
      'rock': 0,
      'ghost': 0,
      'dragon': 0,
      'dark': 0,
      'steel': 0,
      'fairy': 0,
      'normal': 0,
    };
    pokemons = widget.team.pokemons;
    int min = (pokemons.length == 2)
        ? 2
        : (pokemons.length ~/ 2 + pokemons.length % 2);
    for (Pokemon poke in pokemons) {
      final type = poke.types;
      types.forEach((key, value) {
        if (type.contains(key)) {
          setState(() {
            types.update(key, (value) => value + 1);
          });
        }
      });
    }
    types.forEach((key, value) {
      if (value >= min) {
        common.add(key);
      }
    });
    return common;
  }

  List<String> getDebilitatingWeaknesses() {
    Map<String, int> weak = {
      'grass': 0,
      'fire': 0,
      'water': 0,
      'electric': 0,
      'ice': 0,
      'fighting': 0,
      'poison': 0,
      'ground': 0,
      'flying': 0,
      'psychic': 0,
      'bug': 0,
      'rock': 0,
      'ghost': 0,
      'dragon': 0,
      'dark': 0,
      'steel': 0,
      'fairy': 0,
      'normal': 0,
    };
    final List<String> common = [];
    pokemons = widget.team.pokemons;
    int min = (pokemons.length == 2)
        ? 2
        : (pokemons.length ~/ 2 + pokemons.length % 2);
    for (Pokemon poke in pokemons) {
      final type = poke.types;
      for (String tipo in type) {
        Map<String, double> sub = matrix_of_weakness[tipo]!;
        sub.forEach((key, value) {
          if (value == 2) {
            setState(() {
              weak.update(key, (value) => value + 1);
            });
          }
        });
      }
    }
    weak.forEach((key, value) {
      if (value >= min) {
        common.add(key);
      }
    });
    return common;
  }

  List<String> getParcialInmunity() {
    Map<String, int> weak = {
      'grass': 0,
      'fire': 0,
      'water': 0,
      'electric': 0,
      'ice': 0,
      'fighting': 0,
      'poison': 0,
      'ground': 0,
      'flying': 0,
      'psychic': 0,
      'bug': 0,
      'rock': 0,
      'ghost': 0,
      'dragon': 0,
      'dark': 0,
      'steel': 0,
      'fairy': 0,
      'normal': 0,
    };
    final List<String> common = [];
    pokemons = widget.team.pokemons;
    int min = (pokemons.length == 2)
        ? 2
        : (pokemons.length ~/ 2 + pokemons.length % 2);
    for (Pokemon poke in pokemons) {
      final type = poke.types;
      for (String tipo in type) {
        Map<String, double> sub = matrix_of_weakness[tipo]!;
        sub.forEach((key, value) {
          if (value == 0) {
            setState(() {
              weak.update(key, (value) => value + 1);
            });
          }
        });
      }
    }
    weak.forEach((key, value) {
      if (value >= min) {
        common.add(key);
      }
    });
    return common;
  }

  List<String> getStrongerAttacks() {
    Map<String, int> atk = {
      'grass': 0,
      'fire': 0,
      'water': 0,
      'electric': 0,
      'ice': 0,
      'fighting': 0,
      'poison': 0,
      'ground': 0,
      'flying': 0,
      'psychic': 0,
      'bug': 0,
      'rock': 0,
      'ghost': 0,
      'dragon': 0,
      'dark': 0,
      'steel': 0,
      'fairy': 0,
      'normal': 0,
    };
    final List<String> common = [];
    pokemons = widget.team.pokemons;
    int min = (pokemons.length == 2)
        ? 2
        : (pokemons.length ~/ 2 + pokemons.length % 2);
    for (Pokemon poke in pokemons) {
      final type = poke.types;
      for (String tipo in type) {
        Map<String, double> sub = attack_matrix[tipo]!;
        sub.forEach((key, value) {
          if (value == 2) {
            setState(() {
              atk.update(key, (value) => value + 1);
            });
          }
        });
      }
    }
    atk.forEach((key, value) {
      if (value >= min) {
        common.add(key);
      }
    });
    return common;
  }

  AppBar AppBarForMenuButton(BuildContext context) {
    return AppBar(
      // AppBar con título y acciones.
      title: Text(
        'Detalles de ${widget.team.title}',
        style: TextStyles.bodyText,
      ), // Título.
      leading: IconButton(
        // Botón back.
        icon: const Icon(Icons.arrow_back), // Icono.
        onPressed: () => Navigator.pop(context), // Pop navegación.
      ),
      actions: [
        // Acciones.
        IconButton(
          // Botón home.
          icon: const Icon(Icons.home), // Icono.
          onPressed: () {
            // Acción.
            Navigator.pushAndRemoveUntil(
              // Navega a menu y remueve stack.
              context,
              MaterialPageRoute(builder: (context) => MenuPrincipal()),
              (Route<dynamic> route) => false,
            );
          },
          tooltip: 'Volver a Menú Principal', // Tooltip.
        ),
      ],
    );
  }
}
