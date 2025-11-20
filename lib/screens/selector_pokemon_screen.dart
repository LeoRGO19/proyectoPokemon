import 'package:flutter/material.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/data/pokemon.dart';

import 'package:pokedex/screens/comparador_pokemon.dart';
import 'dart:math';
import 'package:pokedex/components/pokedex_components/search_bar_widget.dart';
import 'package:pokedex/components/pokedex_components/category_filter_widget.dart';
import 'package:pokedex/components/pokedex_components/pokemon_card_list.dart';
import 'package:pokedex/data/pokeapi.dart';

import 'package:pokedex/data/favoriteWatcher.dart';
import 'package:pokedex/screens/menu_principal.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/services/database_services.dart';
import 'package:pokedex/core/pokemon_list_controller.dart';

class SelectorPokemonScreen extends StatefulWidget {
  const SelectorPokemonScreen({super.key});

  @override
  State<SelectorPokemonScreen> createState() => _SelectorPokemonScreenState();
}

class _SelectorPokemonScreenState extends State<SelectorPokemonScreen>
    with
        SingleTickerProviderStateMixin,
        PokemonListController<SelectorPokemonScreen> {
  final Set<Pokemon> _seleccionPoke = {};
  // Se mantienen como `late` ya que se inicializan justo antes de la navegación.
  late Pokemon pokeElegido1;
  late Pokemon pokeElegido2;

  final ScrollController _scrollController = ScrollController();
  // CORRECCIÓN: Se asegura que son `List<Pokemon>` mutables.
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _filteredPokemons = [];
  bool _isLoading = true;
  bool _hasMore = false;

  // Variables de filtrado
  String _searchQuery = '';
  Set<String> _selectedCategories = {};
  String _filterMode = 'OR';

  @override
  void initState() {
    super.initState();
    fetchPokemons(context);
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // La lista está cargada completamente, no hay fetch incremental.
  }

  void _resetState() {
    setState(() {
      allPokemons.clear();
      filteredPokemons.clear();
      searchQuery = '';
      selectedCategories.clear();
      filterMode = 'OR';
      isLoading = true;
      hasMore = false;
    });
  }

  // =====================================================================
  // LÓGICA DE CARGA: Desde la Base de Datos (Adaptación de ImcPokedexScreen)
  // =====================================================================

  Future<void> _fetchPokemons() async {
    // Usar fetchPokemons(context) del mixin
    await fetchPokemons(context);
  }

  // =====================================================================
  // LÓGICA DE FILTRADO (Corregida y Separada)
  // =====================================================================

  // CORRECCIÓN: Esta función debe estar FUERA de _applyFilters.
  bool isTypeCategory(String cat) {
    return super.isTypeCategory(cat);
  }

  Future<void> _applyFilters() async {
    await applyFilters(context);
  }

  Future<void> _filterBySearch(String query) async {
    await filterBySearch(query, context);
  }

  Future<void> _onCategoriesChanged(Set<String> selected, String mode) async {
    await onCategoriesChanged(selected, mode, context);
  }

  // =====================================================================
  // LÓGICA DE SELECCIÓN (Intacta)
  // =====================================================================

  void _handlePokemonSelect(Pokemon pokemon) {
    setState(() {
      if (_seleccionPoke.contains(pokemon)) {
        // Deseleccionar
        _seleccionPoke.remove(pokemon);
      } else if (_seleccionPoke.length < 2) {
        // Seleccionar (si hay menos de 2)
        _seleccionPoke.add(pokemon);
      } else {}
    });
  }

  bool _isPokemonCurrentlySelected(Pokemon pokemon) {
    return _seleccionPoke.contains(pokemon);
  }

  // =====================================================================
  // WIDGET BUILD
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Elige los 2 Pokémon a Comparar',
          style: TextStyles.bodyText,
        ),
        backgroundColor: AppColors.backgroundComponentSelected,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(
              _seleccionPoke.length == 2 ? Icons.select_all : Icons.error,
              color: _seleccionPoke.length == 2 ? Colors.green : Colors.red,
            ),
            label: Text(
              _seleccionPoke.length == 2
                  ? 'A PokeComparar!'
                  : 'Faltan Pokémon por seleccionar (${2 - _seleccionPoke.length})',
              style: TextStyles.bodyText,
            ),
            onPressed: _seleccionPoke.length == 2
                ? () {
                    pokeElegido1 = _seleccionPoke.first;
                    pokeElegido2 = _seleccionPoke.last;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComparadorPokemonState(
                          pokeElegido1: pokeElegido1,
                          pokeElegido2: pokeElegido2,
                        ),
                      ),
                    );
                  }
                : null,
          ),
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
          const SizedBox(width: 50),
        ],
      ),
      body: Container(
        color: AppColors.fondoPokedex,
        child: Column(
          children: [
            SearchBarWidget(onChanged: (q) => filterBySearch(q, context)),
            CategoryFilterWidget(
              onFilterChanged: (s, m) => onCategoriesChanged(s, m, context),
            ),
            Expanded(
              child: PokemonCardList(
                pokemons: filteredPokemons,
                scrollController: scrollController,
                isLoading: isLoading,
                hasMore: hasMore,
                onSelected: _handlePokemonSelect,
                isSelected: _isPokemonCurrentlySelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
