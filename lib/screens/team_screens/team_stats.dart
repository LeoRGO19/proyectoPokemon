import 'package:flutter/material.dart';
import 'package:pokedex/components/team_components/team_visualizer.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/components/team_components/team.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:provider/provider.dart';

import 'package:pokedex/components/team_components/add.dart';
import 'package:pokedex/data/exception_handler.dart';
import 'package:pokedex/data/pokeapi.dart';
//import 'package:pokedex/exceptions/exceptions.dart';
import 'package:pokedex/screens/menu_principal.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/components/characteristic_widget.dart';
import 'package:pokedex/components/pokedex_components/stats_chart_widget.dart';
import 'package:pokedex/components/pokedex_components/fav.dart';
import 'package:pokedex/screens/imc_pokemon_details.dart';

//boton que permite agregar pokemon a equipo
class TeamStats extends StatefulWidget {
  final Team team;
  const TeamStats({super.key, required this.team});
  @override
  State<TeamStats> createState() => _TeamStatsState(); // Crea estado.
}

class _TeamStatsState extends State<TeamStats> {
  Map<String, dynamic> _details = {}; // Detalles completos de Pokémon.
  List<Pokemon> pokemons = []; // Lista de evoluciones.
  List<String> _weaknesses = []; // Debilidades basadas en tipos.
  List<String> _types = []; // Tipos.
  bool _isLoading = false; // Flag de carga.
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

  final ScrollController _scrollController =
      ScrollController(); // Controller para scroll en derecha.

  @override
  void dispose() {
    // Limpia recursos.
    _scrollController.dispose(); // Libera controller.
    super.dispose(); // Super dispose.
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
                          characteristics(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Expanded characteristics() {
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
                  /* CharacteristicWidget(
                    title: 'Tipo:',
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
                        : 'No disponible',
                    backgroundColor: AppColors.primary,
                  ),
                  CharacteristicWidget(
                    title: 'Debilidades:',
                    value: _weaknesses.isNotEmpty
                        //? _weaknesses.join(', ').toUpperCase()
                        ? _weaknesses
                              .map(
                                (t) =>
                                    traduccionesTipo[t.toLowerCase()] ??
                                    t, //traduce debilidades
                              )
                              .join(', ')
                              .toUpperCase()
                        : 'No disponible',
                    backgroundColor: AppColors.secondary,
                  ),*/
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
      List<int> statValues = (stats as List<dynamic>)
          .map((s) => s['base_stat'] as int)
          .toList();
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
