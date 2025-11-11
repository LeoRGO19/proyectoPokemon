import 'package:flutter/material.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:pokedex/screens/resultado_comparar.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poke1 = widget.pokeElegido1;
    final poke2 = widget.pokeElegido2;
    final id1 = poke1.url.split("/")[6];
    final id2 = poke2.url.split("/")[6];
    final screenHeight = MediaQuery.of(context).size.height; // Altura pantalla.
    final titleHeight = screenHeight * 0.15; // Altura título.
    final availableHeight = // Altura disponible.
        screenHeight -
        titleHeight -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Estos son los Pokémon a Comparar',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 100),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Center(
                  child: Image.network(
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id1.png',
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: availableHeight * 0.4, // Altura.
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error), // Error icon.
                  ),
                ),

                const SizedBox(width: 10),

                Center(
                  child: Image.network(
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id2.png',
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: availableHeight * 0.4, // Altura.
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error), // Error icon.
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),

            Text(
              'P1: ${poke1.name} vs P2: ${poke2.name}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ResultadoComparar(pokemon1: poke1, pokemon2: poke2),
                  ),
                );
              },
              child: Text("Comparar", style: TextStyles.menuText),
            ),
          ],
        ),
      ),
    );
  }
}
