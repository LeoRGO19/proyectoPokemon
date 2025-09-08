import 'package:flutter/material.dart';
import 'package:pokedex/core/lista_prueba.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  ListaPrueba pokemons = ListaPrueba();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pkmn-HUB')),
      body: Column(
        children: pokemons.lista.entries
            .map((entry) => Text('${entry.key} ${entry.value}'))
            .toList(),
      ),
    );
  }
}
