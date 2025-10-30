import 'package:flutter/material.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/screens/imc_pokedex_screen.dart';
import 'package:pokedex/screens/comparador_pokemon.dart';
import 'package:pokedex/screens/selector_pokemon_screen.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondomain.jpg'),
              fit: BoxFit.cover, // ocupa todo el contenedor
            ),
          ),
          width: double.infinity,
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centra verticalmente los elementos
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImcPokedexScreen()),
                  );
                },
                child: Text("Pokedex", style: TextStyles.menuText),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectorPokemonScreen(),
                    ),
                  );
                },
                child: Text("PokeComparador", style: TextStyles.menuText),
              ),

              // Espacio para agregar más botones o widgets más adelante
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
    );
  }
}

AppBar customAppBar() {
  return AppBar(
    title: Text(
      'Pkmn-HUB',
      style: TextStyles.bodyText.copyWith(
        color: Color.fromARGB(255, 255, 255, 255),
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 41, 37, 37),
    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
  );
}
