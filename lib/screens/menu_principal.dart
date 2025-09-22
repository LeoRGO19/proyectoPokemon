import 'package:flutter/material.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/data/lista_prueba.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/screens/imc_pokedex_screen.dart';

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
        child: SizedBox(
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
                onPressed: null,
                child: Text("Otra funcionalidad", style: TextStyles.menuText),
              ),

              // Espacio para agregar más botones o widgets más adelante
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.background,
    );
  }
}

AppBar customAppBar() {
  return AppBar(
    title: Text('Pkmn-HUB', style: TextStyles.bodyText),
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.black,
  );
}
