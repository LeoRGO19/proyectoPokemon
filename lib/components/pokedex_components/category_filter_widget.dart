import 'package:flutter/material.dart';

// === CategoryFilterWidget.dart ===
// Widget para filtros por categorías: Panel expandible con checkboxes y modo OR/AND.
// Permite seleccionar múltiples categorías organizadas en secciones; actualiza un set de selecciones.
// Para PokeAPI: Construir sectionCategories dinámicamente desde API (ej: fetch tipos, generaciones); agregar callback para filtrado real.
class CategoryFilterWidget extends StatefulWidget {
  const CategoryFilterWidget({super.key});

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  final Map<String, List<String>> sectionCategories = {
    'Generación': [
      'Gen I',
      'Gen II',
      'Gen III',
      'Gen IV',
      'Gen V',
      'Gen VI',
      'Gen VII',
      'Gen VIII',
      'Gen IX',
    ],
    'Tipos': [
      'Grass',
      'Fire',
      'Water',
      'Electric',
      'Ice',
      'Fighting',
      'Poison',
      'Ground',
      'Flying',
      'Psychic',
      'Bug',
      'Rock',
      'Ghost',
      'Dragon',
      'Dark',
      'Steel',
      'Fairy',
    ],
    'Regiones': [
      'Kanto',
      'Johto',
      'Hoenn',
      'Sinnoh',
      'Unova',
      'Kalos',
      'Alola',
      'Galar',
      'Paldea',
    ],
    'Otros': ['Legendary', 'Mythical', 'Starter', 'Pseudo-Legendary', 'Fossil'],
  }; // Cambio con API:
  final Set<String> _selectedCategories = {};
  String _filterMode = 'OR'; // Valor inicial

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: ExpansionTile(
        title: const Text(
          'Filtrar por categorías',
        ), // Título del panel; se expande al tocar.
        leading: const Icon(Icons.filter_list),
        children: [
          // Modo OR/AND
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child:
                rowFilterMode(), //configuracion de botones or/and separada en un método para modular
          ),
          // Contenido con ListView dentro de SizedBox
          SizedBox(
            height:
                MediaQuery.of(context).size.height *
                0.4, // Límite de altura (40% de la ventana)
            child: listViewCategories(context), //
          ),
        ],
      ),
    );

    // Faltante: Botón para limpiar filtros (_selectedCategories.clear(); setState(() {});).
    // Cambio con API: Agregar callback onFilterChanged: Function(Set<String>, String)? para enviar selecciones al padre y filtrar Pokémon.
    // Ej: En onChanged de checkbox y dropdown, llamar widget.onFilterChanged(_selectedCategories, _filterMode);
  }

  ListView listViewCategories(BuildContext context) {
    return ListView(
      shrinkWrap:
          true, //Evita que ListView ocupe espacio infinito, ajustándose a su contenido
      children: sectionCategories.entries.map((entry) {
        // La función recibe 'entry' (MapEntry<String, List<String>>: key=título sección, value=lista categorías) y devuelve Column.
        // Elementos: entry.key (ej: 'Generación'), entry.value (ej: ['Gen I', ...]).
        // Por qué map: Genera widgets dinámicamente por sección; escalable si se agregan más.
        final sectionTitle = entry.key;
        final cats = entry.value; // Lista de categorías por sección.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 8.0),
              child: Text(
                sectionTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
            Wrap(
              spacing: 10.0,
              runSpacing: 5.0,
              alignment: WrapAlignment.start,
              children: cats.map((category) {
                // map transforma cada String en un SizedBox con CheckboxListTile.
                // La función recibe 'category' (String, ej: 'Gen I') y devuelve widget.
                // Elementos: category como título y clave para selección.

                final isSelected = _selectedCategories.contains(
                  category,
                ); //// Verifica si seleccionada.

                return SizedBox(
                  width:
                      (MediaQuery.of(context).size.width - 40) /
                      3.5, // Ancho calculado para 3 por fila; -40 por paddings, /3.5 para espaciado.
                  child: CheckboxListTile(
                    title: Text(category),
                    value: isSelected, // Estado del checkbox.
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          if (value) {
                            _selectedCategories.add(
                              category,
                            ); // Agrega si marcado.
                          } else {
                            _selectedCategories.remove(
                              category,
                            ); // Quita si desmarcado.
                          }
                        });
                        print(
                          'Categorías seleccionadas: ${_selectedCategories.toList()}',
                        );
                      }
                    },
                    controlAffinity: ListTileControlAffinity
                        .leading, //Controla la posición del checkbox en CheckboxListTile (leading = izquierda, trailing = derecha).
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                );
              }).toList(), // Convierte a List<Widget> para children
            ),
          ],
        );
      }).toList(),
    );
  }

  Row rowFilterMode() {
    //función que retorna el row que contiene el Dropdownbutton
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end, // Alinea el dropdown a la derecha;
      children: [
        const Text('Modo: '),
        DropdownButton<String>(
          value: _filterMode, // Valor actual; sincronizado con estado.
          items: const [
            DropdownMenuItem(value: 'OR', child: Text('OR')),
            DropdownMenuItem(value: 'AND', child: Text('AND')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _filterMode = value; // Actualiza estado; redibuja el dropdown.
              });
              print(
                'Modo seleccionado: $_filterMode',
              ); // Placeholder; aquí iría callback al padre para refiltrar.
            }
          },
        ),
      ],
    );
  }
}
