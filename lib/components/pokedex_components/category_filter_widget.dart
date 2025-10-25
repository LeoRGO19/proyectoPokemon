// components/pokedex_components/category_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:pokedex/core/text_styles.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/traductor.dart';
import 'package:pokedex/core/traductor.dart';

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
  final Map<String, List<CategoryFilter>> sectionCategories = {
    // Mapa de secciones y sus categorías, cada item tiene su versión que el usuario verá en español, y otra que ocupa el sistema para filtrar
    'Generación': [
      // Sección de generaciones.
      CategoryFilter(displayName: '1° generación', filterValue: 'generation-i'),
      CategoryFilter(
        displayName: '2° generación',
        filterValue: 'generation-ii',
      ),
      CategoryFilter(
        displayName: '3° generación',
        filterValue: 'generation-iii',
      ),
      CategoryFilter(
        displayName: '4° generación',
        filterValue: 'generation-iv',
      ),
      CategoryFilter(displayName: '5° generación', filterValue: 'generation-v'),
      CategoryFilter(
        displayName: '6° generación',
        filterValue: 'generation-vi',
      ),
      CategoryFilter(
        displayName: '7° generación',
        filterValue: 'generation-vii',
      ),
      CategoryFilter(
        displayName: '8° generación',
        filterValue: 'generation-viii',
      ),
      CategoryFilter(
        displayName: '9° generación',
        filterValue: 'generation-ix',
      ),
    ],
    'Tipos': [
      // Sección de tipos.
      CategoryFilter(displayName: 'Planta', filterValue: 'grass'),
      CategoryFilter(displayName: 'Fuego', filterValue: 'fire'),
      CategoryFilter(displayName: 'Agua', filterValue: 'water'),
      CategoryFilter(displayName: 'Eléctrico', filterValue: 'electric'),
      CategoryFilter(displayName: 'Hielo', filterValue: 'ice'),
      CategoryFilter(displayName: 'Lucha', filterValue: 'fighting'),
      CategoryFilter(displayName: 'Veneno', filterValue: 'poison'),
      CategoryFilter(displayName: 'Tierra', filterValue: 'ground'),
      CategoryFilter(displayName: 'Volador', filterValue: 'flying'),
      CategoryFilter(displayName: 'Psíquico', filterValue: 'psychic'),
      CategoryFilter(displayName: 'Bicho', filterValue: 'bug'),
      CategoryFilter(displayName: 'Roca', filterValue: 'rock'),
      CategoryFilter(displayName: 'Fantasma', filterValue: 'ghost'),
      CategoryFilter(displayName: 'Dragón', filterValue: 'dragon'),
      CategoryFilter(displayName: 'Siniestro', filterValue: 'dark'),
      CategoryFilter(displayName: 'Acero', filterValue: 'steel'),
      CategoryFilter(displayName: 'Hada', filterValue: 'fairy'),
    ],
    'Otros': [
      CategoryFilter(displayName: 'Legendario', filterValue: 'Legendary'),
      CategoryFilter(displayName: 'Singular', filterValue: 'Mythical'),
      CategoryFilter(displayName: 'Favorito', filterValue: 'Favorito'),
    ], // Otros como legendarios y si son favoritos.
    'Colores': [
      // Colores de Pokémon.
      CategoryFilter(displayName: 'Negro', filterValue: 'black'),
      CategoryFilter(displayName: 'Azul', filterValue: 'blue'),
      CategoryFilter(displayName: 'Café', filterValue: 'brown'),
      CategoryFilter(displayName: 'Gris', filterValue: 'gray'),
      CategoryFilter(displayName: 'Verde', filterValue: 'green'),
      CategoryFilter(displayName: 'Rosado', filterValue: 'pink'),
      CategoryFilter(displayName: 'Morado', filterValue: 'purple'),
      CategoryFilter(displayName: 'Rojo', filterValue: 'red'),
      CategoryFilter(displayName: 'Blanco', filterValue: 'white'),
      CategoryFilter(displayName: 'Amarillo', filterValue: 'yellow'),
    ],
    'Hábitats': [
      // Hábitats.
      CategoryFilter(displayName: 'Caverna', filterValue: 'cave'),
      CategoryFilter(displayName: 'Bosque', filterValue: 'forest'),
      CategoryFilter(displayName: 'Pradera', filterValue: 'grassland'),
      CategoryFilter(displayName: 'Montaña', filterValue: 'mountain'),
      CategoryFilter(displayName: 'Campo', filterValue: 'rough-terrain'),
      CategoryFilter(displayName: 'Mar', filterValue: 'sea'),
      CategoryFilter(displayName: 'Urbano', filterValue: 'urban'),
      CategoryFilter(displayName: 'Agua salada', filterValue: 'waters-edge'),
    ],
    'Formas': [
      // Formas corporales.
      CategoryFilter(displayName: 'Bola', filterValue: 'ball'),
      CategoryFilter(displayName: 'Squiggle', filterValue: 'squiggle'),
      CategoryFilter(displayName: 'Pez', filterValue: 'fish'),
      CategoryFilter(displayName: 'Brazos', filterValue: 'arms'),
      CategoryFilter(displayName: 'Blob', filterValue: 'blob'),
      CategoryFilter(displayName: 'Bípedo', filterValue: 'upright'),
      CategoryFilter(displayName: 'Legs', filterValue: 'legs'),
      CategoryFilter(displayName: 'Quadrúpedo', filterValue: 'quadruped'),
      CategoryFilter(displayName: 'Alas', filterValue: 'wings'),
      CategoryFilter(displayName: 'Tentáculos', filterValue: 'tentacles'),
      CategoryFilter(displayName: 'Cabezas', filterValue: 'heads'),
      CategoryFilter(displayName: 'Humanoide', filterValue: 'humanoid'),
      CategoryFilter(displayName: 'Bicho volador', filterValue: 'bug-wings'),
      CategoryFilter(displayName: 'Armadura', filterValue: 'armor'),
    ],
    'Grupos de Huevos': [
      // Grupos de huevos.
      CategoryFilter(displayName: 'Monstruo', filterValue: 'monster'),
      CategoryFilter(displayName: 'Agua 1', filterValue: 'water_1'),
      CategoryFilter(displayName: 'Bicho', filterValue: 'bug'),
      CategoryFilter(displayName: 'Volador', filterValue: 'flying'),
      CategoryFilter(displayName: 'Campo', filterValue: 'field'),
      CategoryFilter(displayName: 'Hada', filterValue: 'fairy'),
      CategoryFilter(displayName: 'Planta', filterValue: 'plant'),
      CategoryFilter(displayName: 'Humanoide', filterValue: 'human_like'),
      CategoryFilter(displayName: 'Agua 3', filterValue: 'water_3'),
      CategoryFilter(displayName: 'Mineral', filterValue: 'mineral'),
      CategoryFilter(displayName: 'Amorfo', filterValue: 'amorphous'),
      CategoryFilter(displayName: 'Agua 2', filterValue: 'water_2'),
      CategoryFilter(displayName: 'Ditto', filterValue: 'ditto'),
      CategoryFilter(displayName: 'Dragón', filterValue: 'dragon'),
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
      children: sectionCategories.entries.map((
        MapEntry<String, List<CategoryFilter>> entry,
      ) {
        // Mapea cada sección.
        final sectionTitle = entry.key; // Título de sección.
        final List<CategoryFilter> cats = entry.value; // Lista de categorías.
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
              children: cats.map((CategoryFilter category) {
                // Mapea cada categoría.
                final isSelected = _selectedCategories.contains(
                  category.filterValue,
                ); // Verifica si seleccionada.
                return SizedBox(
                  // Tamaño fijo para cada item.
                  width:
                      (MediaQuery.of(context).size.width - 40) /
                      3.5, // Ancho calculado.
                  child: CheckboxListTile(
                    // Tile con checkbox.
                    title: Text(
                      category.displayName,
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
                            _selectedCategories.add(
                              category.filterValue,
                            ); // Agrega.
                          } else {
                            _selectedCategories.remove(
                              category.filterValue,
                            ); // Remueve.
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
