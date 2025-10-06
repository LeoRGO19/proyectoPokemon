import 'package:flutter/material.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/text_styles.dart';

// Widget extraído para el gráfico de estadísticas.
// Objetivo: Mostrar barras de stats de forma reusable.
class StatsChartWidget extends StatelessWidget {
  final List<dynamic> stats;

  const StatsChartWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final statNames = [
      // Nombres fijos de stats.
      'HP',
      'Attack',
      'Defense',
      'Sp. Atk',
      'Sp. Def',
      'Speed',
    ];
    final statValues = stats
        .map((s) => s['base_stat'] as int)
        .toList(); // Extrae valores.

    return Column(
      // Columna de rows para cada stat.
      children: List.generate(statNames.length, (index) {
        // Genera por cada stat.
        final value = statValues[index]; // Valor actual.
        final color = index % 2 == 0
            ? AppColors.secondary
            : AppColors.primary; // Alterna colores.
        return Padding(
          // Padding vertical para cada row.
          padding: const EdgeInsets.symmetric(
            vertical: 2.0,
          ), // Espacio vertical.
          child: Row(
            // Row para nombre y barra.
            children: [
              Padding(
                // Padding para nombre.
                padding: const EdgeInsets.only(left: 9.0), // Espacio izquierdo.
                child: SizedBox(
                  // Tamaño fijo para nombre.
                  width:
                      MediaQuery.of(context).size.width *
                      0.08, // Ancho proporcional.
                  child: Text(
                    statNames[index],
                    style: TextStyles.cardText,
                  ), // Texto del nombre.
                ),
              ),
              Expanded(
                // Expande para la barra.
                child: SizedBox(
                  // Contenedor de la barra.
                  height: 16, // Altura fija.
                  child: FractionallySizedBox(
                    // Box que se ajusta fraccionalmente.
                    alignment: Alignment.centerLeft, // Alinea a la izquierda.
                    widthFactor:
                        value / 100, // Factor basado en valor (max 100).
                    child: Container(
                      // Barra coloreada.
                      color: color, // Color alternado.
                      child: Align(
                        // Alinea texto al derecho.
                        alignment: Alignment.centerRight,
                        child: Padding(
                          // Padding para valor.
                          padding: const EdgeInsets.only(
                            right: 4.0,
                          ), // Derecho.
                          child: Text(
                            '$value', // Valor como texto.
                            style: TextStyles.cardText.copyWith(
                              // Estilo con color accent.
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
