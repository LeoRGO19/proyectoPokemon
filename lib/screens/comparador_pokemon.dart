import 'package:flutter/material.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/screens/Resultado_comparar.dart';
import 'package:pokedex/services/database_services.dart';

class ComparadorPokemonState extends StatefulWidget {
  final Pokemon pokeElegido1;
  final Pokemon pokeElegido2;

  const ComparadorPokemonState({
    super.key,
    required this.pokeElegido1,
    required this.pokeElegido2,
  });

  @override
  State<ComparadorPokemonState> createState() => _ComparadorPokemonState();
}

class _ComparadorPokemonState extends State<ComparadorPokemonState> {
  Pokemon? _pokeElegido1;
  Pokemon? _pokeElegido2;
  late Future<List<Pokemon>> _pokemonListFuture;

  @override
  void initState() {
    super.initState();
    _pokemonListFuture = DatabaseService.instance.getPokemon();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PokeComparador', style: TextStyles.bodyText),
        backgroundColor: AppColors.backgroundComponentSelected,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Pokemon>>(
          future: _pokemonListFuture,
          builder: (context, snapshot) {
            final List<Pokemon> pokemonData = snapshot.data!;

            if (_pokeElegido1 == null && pokemonData.isNotEmpty) {
              _pokeElegido1 = pokemonData.first;
            }

            if (_pokeElegido2 == null && pokemonData.isNotEmpty) {
              _pokeElegido2 = pokemonData[1];
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Selecciona dos Pokémon para comparar:',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 150),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Center(
                      child: DropdownMenu<Pokemon>(
                        dropdownMenuEntries: pokemonData
                            .map<DropdownMenuEntry<Pokemon>>((Pokemon pok) {
                              final id = pok.url.split("/")[6];
                              return DropdownMenuEntry<Pokemon>(
                                value: pok,
                                label: '$id. ${pok.name}',
                              );
                            })
                            .toList(),

                        initialSelection: _pokeElegido1,
                        label: const Text('Pokémon 1'),
                        onSelected: (Pokemon? nuevoPokemon) {
                          if (nuevoPokemon != null) {
                            setState(() {
                              _pokeElegido1 = nuevoPokemon;
                            });
                            debugPrint(
                              ' P1 Seleccionado: ${nuevoPokemon.name}',
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Center(
                      child: DropdownMenu<Pokemon>(
                        dropdownMenuEntries: pokemonData
                            .map<DropdownMenuEntry<Pokemon>>((Pokemon pok) {
                              final id = pok.url.split("/")[6];
                              return DropdownMenuEntry<Pokemon>(
                                value: pok,
                                label: '$id. ${pok.name}',
                              );
                            })
                            .toList(),

                        initialSelection: _pokeElegido2,
                        label: const Text('Pokemon 2'),
                        onSelected: (Pokemon? nuevoPokemon2) {
                          if (nuevoPokemon2 != null) {
                            setState(() {
                              _pokeElegido2 = nuevoPokemon2;
                            });
                            debugPrint(
                              'P2 Seleccionado: ${nuevoPokemon2.name}',
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),

                Text(
                  'P1: ${_pokeElegido1!.name} vs P2: ${_pokeElegido2!.name}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultadoComparar(),
                      ),
                    );
                  },
                  child: Text("Comparar", style: TextStyles.menuText),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
