// components/pokedex_components/search_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:pokedex/core/app_colors.dart';

// Este widget representa una barra de búsqueda simple para filtrar Pokémon.
// No maneja errores en la UI; si el onChanged falla, no se muestra nada al usuario.
// Funciona recibiendo un callback onChanged que se llama cada vez que el texto cambia.
// Se puede buscar Pokémon por nombre o ID.
// No hay errores evidentes, pero falta validación en el input como limitar longitud.

class SearchBarWidget extends StatefulWidget {
  final Function(String)?
  onChanged; // Callback para notificar cambios en la búsqueda.
  const SearchBarWidget({
    super.key,
    this.onChanged,
  }); // Constructor con key y callback opcional.

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState(); // Crea el estado asociado.
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller =
      TextEditingController(); // Controlador para manejar el texto del campo.

  @override
  void dispose() {
    // Método para limpiar recursos al destruir el widget.
    _controller.dispose(); // Libera el controlador de texto.
    super.dispose(); // Llama al dispose del padre.
  }

  @override
  Widget build(BuildContext context) {
    // Construye la UI del widget.
    return Container(
      // Contenedor principal con color de fondo.
      color: AppColors.primary,
      child: Padding(
        // Padding alrededor del TextField.
        padding: const EdgeInsets.all(
          10.0,
        ), // Espacio de 10 píxeles en todos lados.
        child: TextField(
          // Campo de texto para la búsqueda.
          controller: _controller, // Asocia el controlador.
          decoration: InputDecoration(
            // Decoración del campo.
            hintText: "Buscar", // Texto placeholder.
            prefixIcon: const Icon(Icons.search), // Icono de lupa al inicio.
            border: OutlineInputBorder(), // Borde outline por defecto.
          ),
          onChanged: widget.onChanged, // Llama al callback con el nuevo valor.
        ),
      ),
    );
  }
}
