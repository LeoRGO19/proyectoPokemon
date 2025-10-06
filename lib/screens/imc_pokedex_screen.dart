import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pokedex/components/pokedex_components/search_bar_widget.dart';
import 'package:pokedex/components/pokedex_components/category_filter_widget.dart';
import 'package:pokedex/components/pokedex_components/pokemon_card_list.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/core/app_colors.dart';
import 'dart:isolate';
import 'package:http/http.dart' as http;

// Pantalla principal de la Pokédex, muestra lista filtrable de Pokémon.
// Funciona cargando Pokémon en batches usando Isolates para no bloquear UI, con infinite scroll.
// Lista todos los Pokémon hasta ID 1025, con filtros por búsqueda y categorías.
// Cómo funciona: initState carga inicial, listener en scroll para más. _fetchPokemons usa Isolate para fetch batch, luego aplica filtros.
// Filtros: Búsqueda por nombre/ID (con fetch específico si exacto), categorías con AND/OR.

// Maneja errores en debugPrint, pero no en UI (usuario no ve si falla fetch). Timeout en PokeApi, pero no retry.
// Hay un pequeño error que es que el scroll de las categorías es difícil de ver
// Falta: Manejo de errores en UI (error cargando, retry, o lo que se quiera agregar).

// este bloque se podría optimizar si se quiere en un futuro, pero en función del tiempo ahora mismo es dificil:
// No se usa (era parte de lógica antigua pero sin embargo podría ser util): _specificSearch y _targetSearchId se setean pero no siempre usan; auto-carga si <5 pero podría loop si siempre <5.
// Limita a 1025 para evitar formas incompletas. _calculateTargetId optimiza fetch limitando por generación max.
// Isolate para fetch evita bloqueo en main thread. _applyFilters filtra en memoria después de fetch.
// Si búsqueda exacta, fetch hasta ese ID. Auto-carga si lista filtrada pequeña.

class ImcPokedexScreen extends StatefulWidget {
  const ImcPokedexScreen({super.key}); // Constructor.

  @override
  State<ImcPokedexScreen> createState() => _ImcPokedexScreenState(); // Crea estado.
}

class _ImcPokedexScreenState extends State<ImcPokedexScreen> {
  final ScrollController _scrollController =
      ScrollController(); // Controller para infinite scroll.
  final List<Pokemon> _allPokemons = []; // Lista total loaded.
  final List<Pokemon> _filteredPokemons = []; // Lista filtrada mostrada.
  bool _isLoading = false; // Flag carga.
  bool _hasMore = true; // Flag más por cargar.
  int _offset = 0; // Offset para API.
  final int _limit = 100; // Batch size.

  String _searchQuery = ''; // Query búsqueda.
  Set<String> _selectedCategories = {}; // Categorías seleccionadas.
  String _filterMode = 'OR'; // Modo filtro.

  int? _targetSearchId; // ID target para búsqueda específica.
  bool _specificSearch = false; // Flag búsqueda exacta.

  final Map<String, int> _generationMaxIds = {
    // Max ID por generación.
    'generation-i': 151,
    'generation-ii': 251,
    'generation-iii': 386,
    'generation-iv': 493,
    'generation-v': 649,
    'generation-vi': 721,
    'generation-vii': 809,
    'generation-viii': 905,
    'generation-ix': 1010,
  };

  // Actualizado: Límite a Pokémon base completos (evita formas con datos incompletos)
  static const int _maxPokedexId = 1025; // Límite max ID.

  @override
  void initState() {
    // Inicializa.
    super.initState();
    _resetState(); // Resetea variables.
    _fetchPokemons(); // Inicia carga.
    _scrollController.addListener(() {
      // Listener scroll.
      if (_scrollController.position.pixels >= // Si cerca del final.
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchPokemons(); // Carga más.
      }
    });
  }

  void _resetState() {
    // Función para reset variables.
    _allPokemons.clear(); // Limpia all.
    _filteredPokemons.clear(); // Limpia filtered.
    _offset = 0; // Reset offset.
    _hasMore = true; // Hay más.
    _searchQuery = ''; // Limpia query.
    _selectedCategories.clear(); // Limpia categorías.
    _filterMode = 'OR'; // Default modo.
    _specificSearch = false; // No específica.
    _targetSearchId = null; // No target.
  }

  Future<void> _fetchPokemons({int? targetId}) async {
    // Función para fetch batch.
    if (_isLoading) return; // Si ya está cargando, sale.
    setState(
      () => _isLoading = true,
    ); // Loading true dado que vamos a hacer fetch
    try {
      int targetOffset = targetId ?? _maxPokedexId; // Target o max.
      // Limitar a 1025 para evitar IDs altos con datos incompletos
      targetOffset = min(targetOffset, _maxPokedexId); // Min.
      List<Pokemon> newPokemons = []; // Nuevos loaded.
      while (_hasMore && _offset < targetOffset) {
        // Mientras más y offset < target.
        int loadLimit = min(_limit, targetOffset - _offset); // Limite batch.

        final receivePort = ReceivePort();
        try {
          await Isolate.spawn(_fetchPokemonsIsolate, {
            'sendPort': receivePort.sendPort,
            'limit': loadLimit,
            'offset': _offset,
          });

          final isolateResult = await receivePort.first; // Espera resultado.
          if (isolateResult is List<Pokemon>) {
            // Si lista.
            newPokemons.addAll(isolateResult); // Agrega.
            setState(() {
              // Actualiza.
              _offset += loadLimit; // Avanza offset.
              if (isolateResult.isEmpty || _offset >= _maxPokedexId) {
                // Si vacío o max.
                _hasMore = false;
              }
              _allPokemons.addAll(isolateResult); // Agrega a all.
              for (var pokemon in isolateResult) {
                // Print debug.
                print(
                  'Pokémon: ${pokemon.name}, Generación: ${pokemon.generation}',
                );
              }
            });
          } else if (isolateResult is String) {
            // Si error string.
            debugPrint('Error desde Isolate: $isolateResult');
          }
        } finally {
          receivePort.close(); // Cierra port.
        }
      }
      // Aplicar filtros después de todos los lotes
      if (newPokemons.isNotEmpty) {
        // Si nuevos.
        await _applyFilters();
      }
    } catch (e) {
      debugPrint('Error cargando Pokémon: $e');
    } finally {
      setState(() => _isLoading = false); // Fin loading.
    }
  }

  static void _fetchPokemonsIsolate(Map<String, dynamic> args) async {
    // Función Isolate.
    final SendPort sendPort = args['sendPort']; // Port.
    final int limit = args['limit']; // Limite.
    final int offset = args['offset']; // Offset.

    await PokeApi.fetchAllPokemonInIsolate(
      // Llama API en Isolate.
      limit: limit,
      offset: offset,
      sendPort: sendPort,
    );
  }

  int? _calculateTargetId(Set<String> categories) {
    // Calcula target ID basado en categorías.
    int maxGenId = 0; // Max gen ID.
    bool hasNonGenFilter = false; // Flag non-gen.

    for (var cat in categories) {
      // Por cada cat.
      if (_generationMaxIds.containsKey(cat)) {
        // Si gen.
        maxGenId = max(maxGenId, _generationMaxIds[cat]!); // Max.
      } else {
        hasNonGenFilter = true; // Non-gen.
      }
    }

    if (hasNonGenFilter) {
      // Si non-gen.
      return _maxPokedexId; // Full.
    } else if (maxGenId > 0) {
      // Si gen max.
      return min(maxGenId, _maxPokedexId); // Min con max.
    }
    return null; // Ninguno.
  }

  Future<void> _filterBySearch(String query) async {
    // Función para filtro por búsqueda.
    setState(() {
      // Actualiza.
      _searchQuery = query.toLowerCase().trim(); // Set query lower trim.
      _filteredPokemons.clear(); // Limpia filtered.
    });

    _specificSearch = false; // Reset específica.
    _targetSearchId = null; // Reset target.
    bool needsFetch = false; // Flag fetch.
    int? targetId;
    if (_searchQuery.isNotEmpty) {
      // Si hay texto
      try {
        Pokemon? basicPokemon;
        if (int.tryParse(_searchQuery) != null) {
          // Si es un id.
          int id = int.parse(_searchQuery);
          if (id > _maxPokedexId) {
            // Si > max.
            // ID demasiado alto: No existe, mostrar no encontrado
            setState(() {
              // Limpia.
              _filteredPokemons.clear();
            });
            return; // Sale.
          }
          basicPokemon = await PokeApi.fetchPokemonById(id);
        } else {
          basicPokemon = await PokeApi.fetchPokemonByName(_searchQuery);
        }
        if (basicPokemon != null) {
          _specificSearch = true;
          final pokemon = await PokeApi.fetchPokemonDetails(
            // Detalles.
            basicPokemon,
            http.Client(),
          );
          targetId = int.parse(pokemon.url.split('/')[6]) + 1; // ID +1.
          _targetSearchId = min(targetId, _maxPokedexId + 1); // Min con max.
          if (_offset < targetId) {
            // Si necesita más.
            needsFetch = true;
          }
        } else {
          // No encontrado
          setState(() {
            // Limpia.
            _filteredPokemons.clear();
          });
          return;
        }
      } catch (e) {
        debugPrint('Error buscando Pokémon: $e');
        setState(() {
          _filteredPokemons.clear();
        });
        return;
      }
    }

    if (needsFetch && targetId != null) {
      // Si necesita fetch.
      await _fetchPokemons(targetId: targetId);
    } else {
      await _applyFilters();
    }
  }

  Future<void> _onCategoriesChanged(Set<String> selected, String mode) async {
    // Función para cambio categorías.
    if (_isLoading) return;
    setState(() {
      _selectedCategories = selected;
      _filterMode = mode;
      _filteredPokemons.clear();
      print('Filtros seleccionados: $_selectedCategories, Modo: $_filterMode');
    });

    final targetId = _calculateTargetId(selected); // Calcula target.
    bool needsFetch = targetId != null && _offset < targetId; // Necesita?

    if (needsFetch) {
      await _fetchPokemons(targetId: targetId);
    } else {
      await _applyFilters();
    }
  }

  Future<void> _applyFilters() async {
    List<Pokemon> results = List.from(_allPokemons); // Copia all.
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
          } else if (pokemon.types
              .map((t) => t.toLowerCase())
              .contains(cat.toLowerCase())) {
            matches = true;
          } else if (cat.toLowerCase() == 'legendary' && pokemon.isLegendary) {
            matches = true;
          } else if (cat.toLowerCase() == 'mythical' && pokemon.isMythical) {
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
            matchesAll = matchesAll && matches; // Si todos coindicen
          } else if (matches) {
            matchesCount++;
          }
        }
        return _filterMode == 'AND'
            ? matchesAll
            : matchesCount > 0; // Retorna basado en modo.
      }).toList(); // Lista filtrada.
    }

    if (_searchQuery.isNotEmpty) {
      // Si hay texto
      results = results.where((pokemon) {
        // Filtra.
        final pokemonId = int.parse(pokemon.url.split('/')[6]); // ID.
        return pokemon.name.toLowerCase().contains(
              _searchQuery,
            ) || // Nombre contiene.
            pokemonId.toString().contains(_searchQuery); // ID contiene.
      }).toList(); // Lista.
    }

    setState(() {
      // Actualiza.
      _filteredPokemons.clear(); // Limpia.
      _filteredPokemons.addAll(
        hasFilters ? results : _allPokemons,
      ); // Agrega filtered o all.
      print('Pokémon filtrados: ${_filteredPokemons.length}'); // Print debug.
    });

    // Auto-carga si la lista filtrada es pequeña y hay más por cargar
    final int currentLength = _filteredPokemons.length; // Longitud actual.
    if (currentLength <
            5 && // Si <5 esto porque para 5 o más aparece el scroll.
        _hasMore &&
        !_isLoading &&
        !(_searchQuery
                .isNotEmpty && // No si búsqueda específica y offset >= target.
            _specificSearch &&
            _offset >= (_targetSearchId ?? 0))) {
      await _fetchPokemons(); // Auto fetch.
    }
  }

  @override
  void dispose() {
    // Limpia.
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex', style: TextStyles.bodyText),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: AppColors.fondoPokedex,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
