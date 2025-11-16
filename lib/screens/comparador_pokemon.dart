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

    return Scaffold(
      appBar: AppBar(
        title: Text('PokeComparador', style: TextStyles.bodyText),
        backgroundColor: AppColors.backgroundComponentSelected,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/poke_comparador.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Estos son los Pokémon a Comparar',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 1.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.network(
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id1.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error), // Error icon.
                        ),
                      ),

                      Expanded(
                        child: Image.network(
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id2.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error), // Error icon.
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),

                Text(
                  '${poke1.name.toUpperCase()} vs ${poke2.name.toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 1.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                Center(
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultadoComparar(
                              pokemon1: poke1,
                              pokemon2: poke2,
                            ),
                          ),
                        );
                      },
                      child: Text("Comparar", style: TextStyles.menuText),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
