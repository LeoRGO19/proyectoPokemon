import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/data/pokemon.dart';
import 'dart:math';
import 'package:pokedex/components/pokedex_components/search_bar_widget.dart';
import 'package:pokedex/components/pokedex_components/category_filter_widget.dart';
import 'package:pokedex/components/pokedex_components/pokemon_card_list.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:pokedex/data/favoriteWatcher.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/services/database_services.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pokedex/data/teamWatcher.dart';
import 'package:pokedex/components/team_components/team.dart';

class AdderPokemonScreen extends StatefulWidget {
  final String title; //titulo del equipo
  const AdderPokemonScreen({super.key, required this.title});

  @override
  State<AdderPokemonScreen> createState() => _AdderPokemonScreenState();
}

class _AdderPokemonScreenState extends State<AdderPokemonScreen>
    with SingleTickerProviderStateMixin {
  final Set<Pokemon> _seleccionPoke = {};

  final ScrollController _scrollController =
      ScrollController(); // Controller para infinite scroll.
  final List<Pokemon> _allPokemons = []; // Lista total loaded.
  final List<Pokemon> _filteredPokemons = []; // Lista filtrada mostrada.
  bool _isLoading = true;
  bool _hasMore = false;
  String _searchQuery = ''; // Query búsqueda.
  Set<String> _selectedCategories = {}; // Categorías seleccionadas.
  String _filterMode = 'OR'; // Modo filtro.

  late final Team team; //equipo al qie le agregaremos pokemon
  late final TeamsProvider teams; //proveedor de equipos

  void _handlePokemonSelect(Pokemon pokemon) {
    setState(() {
      if (_seleccionPoke.contains(pokemon)) {
        // Deseleccionar
        _seleccionPoke.remove(pokemon);
      } else if (_seleccionPoke.length < (6 - team.deck.length)) {
        // Seleccionar (si hay menos del maximo)
        if (!team.isTeamedUp(pokemon.name)) {
          _seleccionPoke.add(pokemon);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pokémon ya estaba en el equipo')),
          );
        }
      } else {}
    });
  }

  bool _isPokemonCurrentlySelected(Pokemon pokemon) {
    return _seleccionPoke.contains(pokemon);
  }

  @override
  void initState() {
    // Inicializa.
    super.initState();
    _fetchPokemons(); // Inicia carga desde DB.
    _scrollController.addListener(_scrollListener);
    setState(() {
      teams = context.read<TeamsProvider>();
      team = teams.getTeam(widget.title)!;
    });
  }

  void _scrollListener() {
    // La lista está cargada completamente, no hay fetch incremental.
  }
  void _resetState() {
    // Función para reset variables.
    _allPokemons.clear(); // Limpia all.
    _filteredPokemons.clear(); // Limpia filtered.// Reset offset.
    _hasMore = true; // Hay más.
    _searchQuery = ''; // Limpia query.
    _selectedCategories.clear(); // Limpia categorías.
    _filterMode = 'OR'; // Default modo.
  }

  Future<void> _fetchPokemons() async {
    // 1. Mostrar Loading
    setState(() {
      _isLoading = true;
      _allPokemons.clear();
      _filteredPokemons.clear();
    });

    // 2. Carga Asíncrona desde DB
    final db = DatabaseService.instance;
    final pokemons = await db.getPokemon();

    // 3. Actualizar Estado (Lista completa)
    setState(() {
      _allPokemons.addAll(pokemons);
      _isLoading = false;
      // Si hay 1025 o más, asumimos que está completa
      _hasMore = pokemons.length < 1025;
    });

    // 4. Aplicar filtros iniciales
    await _applyFilters();
  }

  bool isTypeCategory(String cat) {
    // Lista de tipos válidos
    const validTypes = [
      'normal',
      'fire',
      'water',
      'electric',
      'grass',
      'ice',
      'fighting',
      'poison',
      'ground',
      'flying',
      'psychic',
      'bug',
      'rock',
      'ghost',
      'dragon',
      'dark',
      'steel',
      'fairy',
    ];
    return validTypes.contains(cat.toLowerCase());
  }

  Future<void> _applyFilters() async {
    List<Pokemon> results = List.from(_allPokemons); // Copia all.
    final favoritesProvider = context.read<FavoritesProvider>();
    bool hasFilters =
        _selectedCategories.isNotEmpty ||
        _searchQuery.isNotEmpty; // Hay filtros?

    if (_selectedCategories.isNotEmpty) {
      // Si hay categorías seleccionadas.
      results = results.where((pokemon) {
        bool matchesAll = true; // Para AND.
        int matchesCount = 0; // Para OR.
        for (var cat in _selectedCategories) {
          // Por cat.
          bool matches = false; // Match actual.
          if (pokemon.generation.toLowerCase() == cat.toLowerCase()) {
            matches = true;
          } else if (isTypeCategory(cat)) {
            //chequea que sea tipo
            matches = pokemon.types
                .map((t) => t.toLowerCase())
                .contains(cat.toLowerCase());
          } else if (cat.toLowerCase() == 'legendary' && pokemon.isLegendary) {
            matches = true;
          } else if (cat.toLowerCase() == 'mythical' && pokemon.isMythical) {
            matches = true;
          } else if (cat.toLowerCase() == 'favorito' &&
              favoritesProvider.isFavorite(pokemon.name)) {
            matches = true;
          } else if (pokemon.color.toLowerCase() == cat.toLowerCase()) {
            matches = true;
          } else if (pokemon.habitat?.toLowerCase() == cat.toLowerCase()) {
            matches = true;
          } else if (pokemon.shape?.toLowerCase() == cat.toLowerCase()) {
            matches = true;
          } else if (pokemon.eggGroups.any(
            (egg) => egg.toLowerCase() == cat.toLowerCase(),
          )) {
            matches = true;
          }

          if (_filterMode == 'AND') {
            matchesAll = matchesAll && matches;
          } else {
            if (matches) matchesCount++;
          }
        }

        return _filterMode == 'AND'
            ? matchesAll
            : matchesCount > 0; // Retorna basado en modo.
      }).toList(); // Lista filtrada.
    }

    // CORRECCIÓN: Lógica de búsqueda que faltaba.
    if (_searchQuery.isNotEmpty) {
      // Si hay texto
      results = results.where((pokemon) {
        // Filtra.
        // ASUMIMOS que la URL está completa después de la carga inicial
        final pokemonId = int.tryParse(pokemon.url.split('/')[6] ?? '');
        return pokemon.name.toLowerCase().contains(
              _searchQuery,
            ) || // Nombre contiene.
            (pokemonId?.toString().contains(_searchQuery) ??
                false); // ID contiene.
      }).toList(); // Lista.
    }

    // CORRECCIÓN: Actualización de estado final que faltaba.
    setState(() {
      // Actualiza.
      _filteredPokemons.clear(); // Limpia.
      _filteredPokemons.addAll(
        hasFilters ? results : _allPokemons,
      ); // Agrega filtered o all.
      debugPrint(
        'Pokémon filtrados: ${_filteredPokemons.length}',
      ); // Print debug.
    });
  }

  Future<void> _filterBySearch(String query) async {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
    await _applyFilters();
  }

  Future<void> _onCategoriesChanged(Set<String> selected, String mode) async {
    setState(() {
      _selectedCategories = selected;
      _filterMode = mode;
      debugPrint(
        'Filtros seleccionados: $_selectedCategories, Modo: $_filterMode',
      );
    });
    await _applyFilters();
  }

  @override
  void dispose() {
    // Limpia.
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int max = 6 - team.deck.length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Elige hasta $max pokémon', style: TextStyles.bodyText),
        backgroundColor: AppColors.backgroundComponentSelected,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(_seleccionPoke.length != 0 ? Icons.done : Icons.cancel),
            label: Text(
              _seleccionPoke.isNotEmpty
                  ? 'Agregar a ${team.title}!'
                  : 'No ha seleccionado pokémon',
              style: TextStyles.bodyText,
            ),
            onPressed: () {
              for (Pokemon pokemon in _seleccionPoke) {
                teams.addPokemon(
                  team,
                  pokemon.name,
                  context,
                ); //agrega los pokemon a equipo
              }
              teams.notify();
              Navigator.of(context).pop();
            },
          ),
          SizedBox(width: 40),
        ],
      ),
      body: Container(
        color: AppColors.fondoPokedex,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SearchBarWidget(onChanged: _filterBySearch),
                  CategoryFilterWidget(onFilterChanged: _onCategoriesChanged),
                  Expanded(
                    child: PokemonCardList(
                      pokemons: _filteredPokemons,
                      scrollController: _scrollController,
                      isLoading: _isLoading,
                      hasMore: _hasMore,
                      onSelected: _handlePokemonSelect,
                      isSelected: _isPokemonCurrentlySelected,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: (_seleccionPoke.isNotEmpty),
              //solo se ve al seleccionar pokemons
              child: Container(
                height: 110,
                width: double.infinity,
                color: Color.fromARGB(255, 55, 164, 150),
                child: Center(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(2.0),
                    itemCount: _seleccionPoke.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 15, // 6 columnas
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 0.75,
                        ),
                    itemBuilder: (context, index) {
                      if (index < _seleccionPoke.length) {
                        // Si item real.
                        final pokemon = _seleccionPoke.toList()[index];
                        final id = pokemon.url.split("/")[6];
                        final imageUrl =
                            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png"; // Arte con mejor calidad.

                        return Card(
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            // Shape redondeado.
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Tooltip(
                                  message: 'Deseleccionar ${pokemon.name}',
                                  child: InkWell(
                                    // Clickable.
                                    onTap: () {
                                      setState(() {
                                        _seleccionPoke.remove(
                                          pokemon,
                                        ); //al apretarlo se saca pokemon de lista de pokemon que vamos a agregar
                                      });
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 1.0),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          child: Image.network(
                                            imageUrl,
                                            width: 60.0,
                                            height: 60.0,
                                            fit: BoxFit.contain,
                                            loadingBuilder:
                                                (context, child, progress) {
                                                  if (progress == null)
                                                    return child;
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  );
                                                },
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => // Error.
                                                const Icon(
                                                  Icons.error,
                                                  size: 40,
                                                  color: Colors.red,
                                                ), // Icon.
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Padding(
                          // Loading item.
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
