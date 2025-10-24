// components/pokedex_components/category_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/core/app_colors.dart';

// Este widget permite seleccionar categorías para filtrar Pokémon, como generaciones, tipos, etc.
// Maneja el estado de selección y notifica cambios vía callback.
// Funciona con un ExpansionTile que expande para mostrar checkboxes por sección.

class CategoryFilterWidget extends StatefulWidget {
  final Function(Set<String>, String)?
  onFilterChanged; // Callback para notificar cambios en filtros y modo.

  const CategoryFilterWidget({super.key, this.onFilterChanged}); // Constructor.

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState(); // Crea estado.
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  final Map<String, List<String>> sectionCategories = {
    // Mapa de secciones y sus categorías.
    'Generación': [
      // Sección de generaciones.
      'generation-i',
      'generation-ii',
      'generation-iii',
      'generation-iv',
      'generation-v',
      'generation-vi',
      'generation-vii',
      'generation-viii',
      'generation-ix',
    ],
    'Tipos': [
      // Sección de tipos.
      'grass',
      'fire',
      'water',
      'electric',
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
    ],
    'Otros': [
      'Legendary',
      'Mythical',
      'Favorito',
    ], // Otros como legendarios y si son favoritos.
    'Colores': [
      // Colores de Pokémon.
      'black',
      'blue',
      'brown',
      'gray',
      'green',
      'pink',
      'purple',
      'red',
      'white',
      'yellow',
    ],
    'Hábitats': [
      // Hábitats.
      'cave',
      'forest',
      'grass',
      'meadow',
      'mountain',
      'rough-terrain',
      'sea',
      'urban',
      'waters-edge',
    ],
    'Formas': [
      // Formas corporales.
      'ball',
      'squiggle',
      'fish',
      'arms',
      'blob',
      'upright',
      'legs',
      'quadruped',
      'wings',
      'tentacles',
      'heads',
      'humanoid',
      'bug-wings',
      'armor',
    ],
    'Grupos de Huevos': [
      // Grupos de huevos.
      'monster',
      'water_1',
      'bug',
      'flying',
      'field',
      'fairy',
      'grass',
      'human_like',
      'water_3',
      'mineral',
      'amorphous',
      'water_2',
      'ditto',
      'dragon',
    ],
  };
  final Set<String> _selectedCategories =
      {}; // Conjunto de categorías seleccionadas.
  String _filterMode = 'OR'; // Modo de filtro por defecto OR.

  @override
  Widget build(BuildContext context) {
    // Construye la UI.
    return Padding(
      // Padding alrededor del ExpansionTile.
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 8.0,
      ), // Espacio horizontal y vertical.
      child: ExpansionTile(
        // Tile expandible.
        title: Text(
          'Filtrar por categorías',
          style: TextStyles.bodyText,
        ), // Título.
        leading: Icon(
          Icons.filter_list,
          color: AppColors.primary,
        ), // Icono de filtro.
        children: [
          // Hijos cuando expandido.
          Padding(
            // Padding para el modo de filtro.
            padding: const EdgeInsets.only(bottom: 8.0), // Espacio inferior.
            child: rowFilterMode(), // Widget para seleccionar modo.
          ),
          ElevatedButton(
            // Botón para limpiar filtros.
            style: ElevatedButton.styleFrom(
              // Estilo del botón.
              backgroundColor: AppColors.primary, // Color primario.
              foregroundColor: AppColors.accent, // Color de texto.
            ),
            onPressed: () {
              // Acción al presionar.
              setState(() {
                // Actualiza estado.
                _selectedCategories.clear(); // Limpia selección.
              });
              if (widget.onFilterChanged != null) {
                // Notifica si hay callback.
                widget.onFilterChanged!({}, _filterMode);
              }
            },
            child: Text(
              'Limpiar filtros',
              style: TextStyles.menuText,
            ), // Texto del botón.
          ),
          SizedBox(
            // Contenedor con altura fija para la lista.
            height:
                MediaQuery.of(context).size.height *
                0.4, // 40% de la altura de pantalla.
            child: listViewCategories(context), // Lista de categorías.
          ),
        ],
      ),
    );
  }

  ListView listViewCategories(BuildContext context) {
    // Función para construir la lista de categorías.
    return ListView(
      // ListView para secciones.
      shrinkWrap: true, // Se ajusta al contenido.
      children: sectionCategories.entries.map((entry) {
        // Mapea cada sección.
        final sectionTitle = entry.key; // Título de sección.
        final cats = entry.value; // Lista de categorías.
        return Column(
          // Columna por sección.
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinea a la izquierda.
          children: [
            Padding(
              // Padding para título de sección.
              padding: const EdgeInsets.only(
                left: 16.0,
                bottom: 8.0,
                top: 8.0,
              ), // Espacios.
              child: Text(
                sectionTitle,
                style: TextStyles.bodyText,
              ), // Texto del título.
            ),
            Wrap(
              // Wrap para checkboxes.
              spacing: 10.0, // Espacio horizontal.
              runSpacing: 5.0, // Espacio vertical.
              alignment: WrapAlignment.start, // Alinea al inicio.
              children: cats.map((category) {
                // Mapea cada categoría.
                final isSelected = _selectedCategories.contains(
                  category,
                ); // Verifica si seleccionada.
                return SizedBox(
                  // Tamaño fijo para cada item.
                  width:
                      (MediaQuery.of(context).size.width - 40) /
                      3.5, // Ancho calculado.
                  child: CheckboxListTile(
                    // Tile con checkbox.
                    title: Text(
                      category,
                      style: TextStyles.cardText,
                    ), // Título de categoría.
                    value: isSelected, // Valor del checkbox.
                    onChanged: (value) {
                      // Acción al cambiar.
                      if (value != null) {
                        // Si valor no nulo.
                        setState(() {
                          // Actualiza estado.
                          if (value) {
                            // Si seleccionado.
                            _selectedCategories.add(category); // Agrega.
                          } else {
                            _selectedCategories.remove(category); // Remueve.
                          }
                        });
                        if (widget.onFilterChanged != null) {
                          // Notifica.
                          widget.onFilterChanged!(
                            _selectedCategories,
                            _filterMode,
                          );
                        }
                      }
                    },
                    controlAffinity:
                        ListTileControlAffinity.leading, // Checkbox al inicio.
                    contentPadding: EdgeInsets.zero, // Sin padding.
                    dense: true, // Denso para ahorrar espacio.
                  ),
                );
              }).toList(), // Convierte a lista.
            ),
          ],
        );
      }).toList(), // Convierte a lista.
    );
  }

  Row rowFilterMode() {
    // Función para el row del modo de filtro.
    return Row(
      // Row para alinear elementos.
      mainAxisAlignment: MainAxisAlignment.end, // Alinea al final.
      children: [
        Text('Modo: ', style: TextStyles.bodyText), // Texto "Modo:".
        DropdownButton<String>(
          // Dropdown para seleccionar modo.
          value: _filterMode, // Valor actual.
          items: const [
            // Items fijos.
            DropdownMenuItem(value: 'OR', child: Text('OR')),
            DropdownMenuItem(value: 'AND', child: Text('AND')),
          ],
          onChanged: (value) {
            // Acción al cambiar.
            if (value != null) {
              // Si no nulo.
              setState(() {
                // Actualiza estado.
                _filterMode = value; // Cambia modo.
              });
              if (widget.onFilterChanged != null) {
                // Notifica.
                widget.onFilterChanged!(_selectedCategories, _filterMode);
              }
            }
          },
        ),
      ],
    );
  }
}
