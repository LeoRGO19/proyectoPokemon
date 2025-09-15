import 'package:flutter/material.dart';

// === SearchBarWidget.dart ===
// Widget reutilizable para barra de búsqueda: Un TextField simple con callback para cambios.
// Permite al usuario ingresar texto para filtrar; envía cambios al padre.
// Para PokeAPI: El callback onChanged filtraría una lista dinámica de Pokémon en tiempo real.
class SearchBarWidget extends StatefulWidget {
  final Function(String)?
  onChanged; // Callback para enviar el texto ingresado; opcional, pero requerido para funcionalidad.
  // Por qué Function(String)?: Recibe el valor del texto cada vez que cambia, permitiendo filtrado reactivo.
  const SearchBarWidget({super.key, this.onChanged});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // Libera el controlador al destruir el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: _controller, // Asocia el controlador para manejar input.
        decoration: InputDecoration(
          hintText: "Buscar",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: widget.onChanged, // Envía el texto al callback
      ),
    );
  }
}
