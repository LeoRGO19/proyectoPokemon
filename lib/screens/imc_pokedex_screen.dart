import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pokedex/components/pokedex_components/search_bar_widget.dart';
import 'package:pokedex/components/pokedex_components/category_filter_widget.dart';
import 'package:pokedex/components/pokedex_components/pokemon_card_list.dart';
import 'package:pokedex/data/pokeapi.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/core/pokemon_list_controller.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/data/favoriteWatcher.dart';
import 'package:pokedex/screens/imc_pokemon_details.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/services/database_services.dart';

class ImcPokedexScreen extends StatefulWidget {
  const ImcPokedexScreen({super.key});

  @override
  State<ImcPokedexScreen> createState() => _ImcPokedexScreenState();
}

class _ImcPokedexScreenState extends State<ImcPokedexScreen> {
  // CORRECCIÓN: Se quita 'final' y se añaden variables de estado faltantes (isLoading, hasMore).
  final ScrollController _scrollController = ScrollController();
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _filteredPokemons = [];
  bool _isLoading =
      true; // Añadido para resolver el error 'missing_required_argument'
  bool _hasMore =
      false; // Añadido para resolver el error 'missing_required_argument'

  // Variables de filtrado
  String _searchQuery = '';
  Set<String> _selectedCategories = {};
  String _filterMode = 'OR';

  @override
  void initState() {
    super.initState();
    // No es necesario _resetState si las listas se inicializan vacías.
    _fetchPokemons(); // Inicia carga desde DB.
    // CORRECCIÓN: Se añade el listener que estaba faltando en el snippet
    _scrollController.addListener(_scrollListener);
  }

  // CORRECCIÓN: Se añade el _scrollListener para evitar posibles errores de Null Safety si se usa.
  void _scrollListener() {
    // La lista está cargada completamente, no hay fetch incremental.
  }

  // FIX: Se envuelve _allPokemons.clear() en setState.
  void _resetState() {
    setState(() {
      _allPokemons.clear();
      _filteredPokemons.clear();
      _searchQuery = '';
      _selectedCategories.clear();
      _filterMode = 'OR';
      // Las variables de carga deben estar aquí si se usa _resetState
      _isLoading = true;
      _hasMore = false;
    });
  }

  void _handlePokemonNavigation(Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(
          // CORREGIDO
          pokemon: pokemon,
        ),
      ),
    );
  }

  bool _isPokemonNeverSelected(Pokemon pokemon) {
    return false; // Nunca hay selección en la Pokédex normal
  }

  // FIX: _fetchPokemons: Se corrige la lógica de setState para que sea síncrona.
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

  Future<void> _filterBySearch(String query) async {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
    // Se elimina _filteredPokemons.clear() aquí, ya que _applyFilters lo hace
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
    // Se elimina _filteredPokemons.clear() aquí, ya que _applyFilters lo hace
    await _applyFilters();
  }

  bool isTypeCategory(String cat) {
    // Lista de tipos válidos (Dejo tu lista intacta)
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

  // FIX: Cierre incorrecto de la función corregido.
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

    if (_searchQuery.isNotEmpty) {
      // Si hay texto
      results = results.where((pokemon) {
        // Filtra.
        // ASUMIMOS que la URL está completa después de la carga inicial
        final pokemonId = int.tryParse(pokemon.url.split('/')[6]);
        return pokemon.name.toLowerCase().contains(
              _searchQuery,
            ) || // Nombre contiene.
            (pokemonId?.toString().contains(_searchQuery) ??
                false); // ID contiene.
      }).toList(); // Lista.
    }

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
    // Se elimina el } extra.
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // FIX: Se asegura la existencia del método build.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex', style: TextStyles.bodyText),
        backgroundColor: AppColors.backgroundComponentSelected,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: AppColors.fondoPokedex,
        child: Column(
          children: [
            // Los métodos ahora están correctamente definidos en el scope:
            SearchBarWidget(onChanged: _filterBySearch),
            CategoryFilterWidget(onFilterChanged: _onCategoriesChanged),
            Expanded(
              child: PokemonCardList(
                pokemons: _filteredPokemons,
                scrollController: _scrollController,
                isLoading: _isLoading, // FIX: Parámetro requerido añadido.
                hasMore: _hasMore, // FIX: Parámetro requerido añadido.
                onSelected: _handlePokemonNavigation,
                isSelected: _isPokemonNeverSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
