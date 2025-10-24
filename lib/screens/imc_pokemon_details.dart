import 'package:flutter/material.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/screens/menu_principal.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/components/characteristic_widget.dart';
import 'package:pokedex/components/pokedex_components/stats_chart_widget.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/data/favoriteWatcher.dart';
import 'package:pokedex/screens/fav.dart';

// Pantalla principal de detalles de Pokémon.
// Esta pantalla carga y muestra detalles detallados de un Pokémon específico.
// Funciona fetching data asíncrona en initState, usando PokeApi para obtener detalles, evoluciones, descripción, etc.
// Proporciona una vista completa con stats, evoluciones, características, imagen animada.

//La UI es responsive con LayoutBuilder, dividiendo en columnas izquierda (imagen/stats/evoluciones) y derecha (características con scroll).
//Puede que sea necesario manejar errores de modo que se vea en la UI
// Falta: Manejo de errores en UI más amigable, como retry button o mensajes específicos.

// Falta: Traducir a español si es que se quiere
// Posibles mejoras: Agregar más datos como moves. El scroll de la parte derecha podría tener un color, se intentó pero no funcionó
// Si no hay descripción en 'es', fallback a 'en', sino 'No disponible'. Similar para category.

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon; // Pokémon base para fetch detalles.

  const PokemonDetailScreen({super.key, required this.pokemon}); // Constructor.

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState(); // Crea estado.
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Map<String, dynamic> _details = {}; // Detalles completos de Pokémon.
  List<Map<String, dynamic>> _evolutions = []; // Lista de evoluciones.
  String _description = ''; // Descripción en texto.
  List<String> _weaknesses = []; // Debilidades basadas en tipos.
  String _generation = ''; // Generación.
  List<String> _types = []; // Tipos.
  String _weight = ''; // Peso formateado.
  String _height = ''; // Altura formateada.
  String _mainAbility = ''; // Habilidad principal.
  String _category = ''; // Categoría (genus).
  bool _isLoading = true; // Flag de carga.
  String _error = ''; // Mensaje de error.

  @override
  void initState() {
    // Inicializa estado.
    super.initState(); // Llama super.
    _fetchDetails(); // Inicia fetch asíncrono.
  }

  Future<void> _fetchDetails() async {
    // Función para fetch todos los datos.
    try {
      // Try-catch para errores.
      final details = await PokeApi.fetchPokemonFullDetails(
        widget.pokemon.url,
      ); // Fetch detalles full.
      final speciesUrl = widget.pokemon.url.replaceAll(
        // Construye URL de species.
        'pokemon/',
        'pokemon-species/',
      );
      final detailedPokemon = await PokeApi.fetchPokemonDetails(
        // Fetch detalles extendidos.
        widget.pokemon,
        http.Client(),
      );

      final results = await Future.wait([
        // Paraleliza fetches.
        PokeApi.fetchEvolutionChain(speciesUrl), // Evoluciones.
        PokeApi.fetchDescription(speciesUrl), // Descripción.
        PokeApi.fetchPokemonSpecies(speciesUrl), // Species data.
      ]).timeout(const Duration(seconds: 10)); // Timeout global.

      final evolutions =
          results[0] as List<Map<String, dynamic>>; // Extrae evoluciones.
      final description = results[1] as String; // Descripción.
      final speciesData = results[2] as Map<String, dynamic>; // Species.
      final weaknesses = await PokeApi.fetchWeaknesses(
        detailedPokemon.types,
      ); // Debilidades.

      final weight = details['weight'] / 10.0; // Formatea peso.
      final height = details['height'] / 10.0; // Formatea altura.
      final abilities = details['abilities'] as List; // Abilities list.
      final mainAbility = abilities.firstWhere(
        // Encuentra principal no hidden.
        (ability) => !ability['is_hidden'],
        orElse: () => {
          'ability': {'name': 'No disponible'},
        },
      )['ability']['name']; // Nombre o default.
      final genera = speciesData['genera'] as List; // Genera list.
      final category = genera.firstWhere(
        // Encuentra en 'es'.
        (entry) => entry['language']['name'] == 'es',
        orElse: () => {'genus': 'No disponible'},
      )['genus']; // Genus o default.

      setState(() {
        // Actualiza estado.
        _details = details; // Asigna detalles.
        _evolutions = evolutions; // Evoluciones.
        _description = description; // Descripción.
        _weaknesses = weaknesses; // Debilidades.
        _generation = detailedPokemon.generation; // Generación.
        _types = detailedPokemon.types; // Tipos.
        _weight = weight.toStringAsFixed(1); // Peso string.
        _height = height.toStringAsFixed(1); // Altura string.
        _mainAbility = mainAbility.toUpperCase(); // Habilidad upper.
        _category = category; // Categoría.
        _isLoading = false; // Fin de carga.
      });
    } catch (e) {
      // Catch error.
      setState(() {
        // Actualiza con error.
        _error = e.toString(); // Mensaje.
        _isLoading = false; // Fin carga.
      });
    }
  }

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
              child: Text("Error: $_error", style: TextStyles.bodyText),
            ) // Mensaje error.
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
                      color: Color.fromRGBO(0, 0, 0, 1), // Negro.
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Centra texto.
                        children: [
                          Text(
                            // Texto ID y nombre.
                            '#${_details['id']} ${widget.pokemon.name.toUpperCase()}',
                            style: TextStyles.bodyText.copyWith(
                              // Estilo con color blanco y size 24.
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 24,
                            ),
                          ),
                          //se agrega  botón para marcar como favorito
                          SizedBox(
                            width: titleHeight,
                            height: titleHeight,
                            child: BotonFavorito(pokemon: widget.pokemon),
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
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ), // Blanco.
                                    child: Row(
                                      // Row para stats e imagen.
                                      children: [
                                        // Estadísticas (50% del ancho de la columna izquierda)
                                        stats(),
                                        // GIF del Pokémon (50% del ancho de la columna izquierda)
                                        gifOrImg(availableHeight),
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
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ), // Blanco.
                                    child: Column(
                                      // Columna para título y list.
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Izquierda.
                                      children: [
                                        Padding(
                                          // Padding título.
                                          padding: const EdgeInsets.all(
                                            8.0,
                                          ), // All.
                                          child: Text(
                                            'Evoluciones:',
                                            style:
                                                TextStyles.bodyText, // Estilo.
                                          ),
                                        ),
                                        Expanded(
                                          // Expande listview.
                                          child: ListView.builder(
                                            // Builder horizontal.
                                            scrollDirection:
                                                Axis.horizontal, // Horizontal.
                                            itemCount:
                                                _evolutions.length, // Count.
                                            itemBuilder: (context, index) {
                                              // Builder.
                                              final evolution =
                                                  _evolutions[index]; // Evolución actual.
                                              final id = evolution['url'].split(
                                                '/',
                                              )[6]; // ID de URL.
                                              return Padding(
                                                // Padding horizontal.
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4.0,
                                                    ), // Espacio.
                                                child: Card(
                                                  // Card clickable.
                                                  child: InkWell(
                                                    // Para tap.
                                                    onTap: () async {
                                                      // 🔹 Navigate a detalles de evolución
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PokemonDetailScreen(
                                                                pokemon: Pokemon(
                                                                  name:
                                                                      evolution['name'],
                                                                  url:
                                                                      evolution['url'],
                                                                ),
                                                              ),
                                                        ),
                                                      );
                                                      /*onTap: () {
                                                      // Navega a detalles de evolución.
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PokemonDetailScreen(
                                                                pokemon: Pokemon(
                                                                  name:
                                                                      evolution['name'],
                                                                  url:
                                                                      evolution['url'],
                                                                ),
                                                              ),
                                                        ),
                                                      );*/
                                                    },
                                                    child: Column(
                                                      // Columna imagen y texto.
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center, // Centro.
                                                      children: [
                                                        Image.network(
                                                          // Imagen network.
                                                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
                                                          width:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.1, // Ancho proporcional.
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
                                                          evolution['name']
                                                              .toUpperCase(), // Nombre upper.
                                                          style: TextStyles
                                                              .cardText, // Estilo.
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
                          // Columna derecha: 50% ancho, todas las características visibles
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
                  // Lista de widgets extraídos.
                  CharacteristicWidget(
                    title: 'Descripción:',
                    value: _description.isNotEmpty
                        ? _description
                        : 'No disponible',
                    backgroundColor: AppColors.primary,
                  ),
                  CharacteristicWidget(
                    title: 'Categoría:',
                    value: _category.isNotEmpty ? _category : 'No disponible',
                    backgroundColor: AppColors.secondary,
                  ),
                  CharacteristicWidget(
                    title: 'Tipo:',
                    value: _types.isNotEmpty
                        ? _types.join(', ').toUpperCase()
                        : 'No disponible',
                    backgroundColor: AppColors.primary,
                  ),
                  CharacteristicWidget(
                    title: 'Generación:',
                    value: _generation.isNotEmpty
                        ? _generation
                        : 'No disponible',
                    backgroundColor: AppColors.secondary,
                  ),
                  CharacteristicWidget(
                    title: 'Peso:',
                    value: _weight.isNotEmpty ? '$_weight kg' : 'No disponible',
                    backgroundColor: AppColors.primary,
                  ),
                  CharacteristicWidget(
                    title: 'Altura:',
                    value: _height.isNotEmpty ? '$_height m' : 'No disponible',
                    backgroundColor: AppColors.secondary,
                  ),
                  CharacteristicWidget(
                    title: 'Habilidad Principal:',
                    value: _mainAbility.isNotEmpty
                        ? _mainAbility
                        : 'No disponible',
                    backgroundColor: AppColors.primary,
                  ),
                  CharacteristicWidget(
                    title: 'Debilidades:',
                    value: _weaknesses.isNotEmpty
                        ? _weaknesses.join(', ').toUpperCase()
                        : 'No disponible',
                    backgroundColor: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded gifOrImg(double availableHeight) {
    return Expanded(
      // Expande.
      child: Padding(
        // Padding imagen.
        padding: const EdgeInsets.all(8.0), // All.
        child: Image.network(
          // Imagen network animada.
          _details['sprites']['versions']['generation-v']['black-white']['animated']['front_default'] ??
              'https://via.placeholder.com/150', // URL o placeholder.
          height: availableHeight * 0.35, // Altura proporcional.
          fit: BoxFit.contain, // Contiene.
          // Si falla imagen animada, fallback a estática, pero si falla estática, asset local.
          errorBuilder: (context, error, stackTrace) {
            // Manejo error.
            // Fallback a la imagen estática si el sprite animado falla
            final staticUrl =
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${_details['id']}.png'; // URL estática.
            return Image.network(
              staticUrl, // Carga estática.
              height: availableHeight * 0.35, // Altura.
              fit: BoxFit.contain, // Contiene.
              errorBuilder: (context, error, stackTrace) {
                // Otro error.
                // Si falla la imagen estática, usa el placeholder local
                return Image.asset(
                  'assets/images/errorApiVisual.png', // Asset local.
                );
              },
            );
          },
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
          StatsChartWidget(stats: _details['stats']), // Widget extraído.
        ],
      ),
    );
  }

  AppBar AppBarForMenuButton(BuildContext context) {
    return AppBar(
      // AppBar con título y acciones.
      title: Text(
        'Detalles del Pokémon',
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
