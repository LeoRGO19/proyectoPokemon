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
import 'package:pokedex/data/favoriteWatcher.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/services/database_services.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
    final db = DatabaseService.instance;
    if (Platform.isWindows || Platform.isLinux) {
      //crea base de datos correctamente
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final int dataSaved = await db
        .checkData(); //si es que los pokemon estan en la base de datos los carga desde ahí y no desde la PokeApi
    if (dataSaved == 1025 && _offset == 0) {
      print('Todos los pokémon están en la base de datos, subiendo...');
      final saved = await db.getPokemon();
      setState(() {
        _allPokemons.clear(); //me aseguro de no subir dos veces
        _allPokemons.addAll(saved);
        _isLoading = false;
        _hasMore = false;
      });
      _filteredPokemons.clear();
      await _applyFilters();
      return;
    }
    // Función para fetch batch.
    if (_isLoading) return; // Si ya está cargando, sale.
    setState(
      () => _isLoading = true,
    ); // Loading true dado que vamos a hacer fetch
    try {
      if (dataSaved != 0) {
        //si hay datos en la base de datos los carga
        final saved = await db.getPokemon();
        _allPokemons.clear(); //por si hay duplicates
        _allPokemons.addAll(saved);
        _applyFilters(); //para verlos
      }
      _offset = dataSaved; //comienza desde el ultimo pokemon guardado
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
              db.addPokemon(isolateResult);
              _allPokemons.addAll(isolateResult); // Agrega a all.
              _applyFilters(); //permite que pokémon se vean
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
    setState(() {
      _searchQuery = query.toLowerCase().trim();
      _filteredPokemons.clear();
    });

    _specificSearch = false;
    _targetSearchId = null;
    bool needsFetch = false;
    int? targetId;

    if (_searchQuery.isNotEmpty) {
      try {
        Pokemon? basicPokemon;
        if (int.tryParse(_searchQuery) != null) {
          int id = int.parse(_searchQuery);
          if (id > _maxPokedexId) {
            //removido: setState(() { // Limpia._filteredPokemons.clear();});return;.
          } else {
            basicPokemon = await PokeApi.fetchPokemonById(
              id,
            ); // Fetch exacto por ID.
          }
        } else {
          basicPokemon = await PokeApi.fetchPokemonByName(
            _searchQuery,
          ); // Fetch exacto por nombre.
        }

        if (basicPokemon != null) {
          // Si éxito en exacto (ID o nombre full).
          _specificSearch = true;
          final pokemon = await PokeApi.fetchPokemonDetails(
            basicPokemon,
            http.Client(),
          );
          targetId = int.parse(pokemon.url.split('/')[6]) + 1;
          _targetSearchId = min(targetId, _maxPokedexId + 1);
          if (_offset < targetId) {
            needsFetch = true;
          }
        }
        // REMOVIDO: No hay 'else { clear() return }'; siempre continúa a _applyFilters.
      } catch (e) {
        debugPrint('Error buscando Pokémon exacto: $e');
        // REMOVIDO: No clear ni return; permite filtrado local.
      }
    }

    if (needsFetch && targetId != null) {
      await _fetchPokemons(
        targetId: targetId,
      ); // Solo fetch extra si exacto éxito.
    } else {
      await _applyFilters(); // SIEMPRE aplica filtro local (parciales, vacíos, o combinado).
    }
  }

  Future<void> _onCategoriesChanged(Set<String> selected, String mode) async {
    // Función para cambio categorías.
    //if (_isLoading) return;
    setState(() {
      _selectedCategories = selected;
      _filterMode = mode;
      _filteredPokemons.clear();
      print('Filtros seleccionados: $_selectedCategories, Modo: $_filterMode');
    });

    final targetId = _calculateTargetId(selected); // Calcula target.
    bool needsFetch = targetId != null && _offset < targetId; // Necesita?

    if (needsFetch && !_isLoading) {
      await _fetchPokemons(targetId: targetId);
    } else {
      //si no ha terminado de cargar no nos preocupamos con fetch y mostramos lo que tenemos
      await _applyFilters();
    }
  }

  Future<void> _applyFilters() async {
    List<Pokemon> results = List.from(_allPokemons); // Copia all.
    final favoritesProvider = context
        .read<
          FavoritesProvider
        >(); //servirá para revisar si pokémon es favorito
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
