import 'package:flutter/material.dart';
import 'package:pokedex/core/text_styles.dart';

// Widget extraído para mostrar una característica individual.
// Objetivo: Reusar para cada par título-valor en la columna derecha de la screen detallada de las card.

class CharacteristicWidget extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;

  const CharacteristicWidget({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 8.0,
      ), // Margen inferior para separación.
      padding: const EdgeInsets.all(8.0), // Padding interno.
      decoration: BoxDecoration(
        // Decoración con borde redondeado.
        borderRadius: BorderRadius.circular(8.0), // Radio de borde.
      ),
      child: Column(
        // Columna para título y valor.
        crossAxisAlignment: CrossAxisAlignment.start, // Alinea a la izquierda.
        children: [
          Text(title, style: TextStyles.bodyText), // Título con estilo body.
          Text(
            value, // Valor de la característica.
            style: TextStyles.cardText, // Estilo card para valor.
            softWrap: true, // Permite wrap de texto.
            overflow: TextOverflow.clip, // Corta si excede.
            maxLines: null, // Sin límite de líneas.
          ),
        ],
      ),
    );
  }
}
