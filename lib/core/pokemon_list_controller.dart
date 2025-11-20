import 'package:flutter/material.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/services/database_services.dart';
import 'package:pokedex/data/favoriteWatcher.dart';
import 'package:provider/provider.dart';

mixin PokemonListController<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  List<Pokemon> allPokemons = [];
  List<Pokemon> filteredPokemons = [];
  bool isLoading = true;
  bool hasMore = false;
  String searchQuery = '';
  Set<String> selectedCategories = {};
  String filterMode = 'OR';

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchPokemons(BuildContext context) async {
    setState(() {
      isLoading = true;
      allPokemons.clear();
      filteredPokemons.clear();
    });
    final db = DatabaseService.instance;
    final pokemons = await db.getPokemon();
    setState(() {
      allPokemons.addAll(pokemons);
      isLoading = false;
      hasMore = pokemons.length < 1025;
    });
    await applyFilters(context);
  }

  bool isTypeCategory(String cat) {
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

  Future<void> applyFilters(BuildContext context) async {
    List<Pokemon> results = List.from(allPokemons);
    final favoritesProvider = context.read<FavoritesProvider>();
    bool hasFilters = selectedCategories.isNotEmpty || searchQuery.isNotEmpty;
    if (selectedCategories.isNotEmpty) {
      results = results.where((pokemon) {
        bool matchesAll = true;
        int matchesCount = 0;
        for (var cat in selectedCategories) {
          bool matches = false;
          if (pokemon.generation.toLowerCase() == cat.toLowerCase()) {
            matches = true;
          } else if (isTypeCategory(cat)) {
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
          if (filterMode == 'AND') {
            matchesAll = matchesAll && matches;
          } else {
            if (matches) matchesCount++;
          }
        }
        return filterMode == 'AND' ? matchesAll : matchesCount > 0;
      }).toList();
    }
    if (searchQuery.isNotEmpty) {
      results = results.where((pokemon) {
        final pokemonId = int.tryParse(pokemon.url.split('/')[6] ?? '');
        return pokemon.name.toLowerCase().contains(searchQuery) ||
            (pokemonId?.toString().contains(searchQuery) ?? false);
      }).toList();
    }
    setState(() {
      filteredPokemons.clear();
      filteredPokemons.addAll(hasFilters ? results : allPokemons);
      debugPrint('Pokémon filtrados: [32m${filteredPokemons.length}[0m');
    });
  }

  Future<void> filterBySearch(String query, BuildContext context) async {
    setState(() {
      searchQuery = query.toLowerCase().trim();
    });
    await applyFilters(context);
  }

  Future<void> onCategoriesChanged(
    Set<String> selected,
    String mode,
    BuildContext context,
  ) async {
    setState(() {
      selectedCategories = selected;
      filterMode = mode;
      debugPrint(
        'Filtros seleccionados: $selectedCategories, Modo: $filterMode',
      );
    });
    await applyFilters(context);
  }
}
