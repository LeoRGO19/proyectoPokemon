import 'package:flutter/material.dart';
import 'package:pokedex/core/app_colors.dart';
import 'package:pokedex/core/text_styles.dart';

class ResultadoComparar extends StatefulWidget {
  const ResultadoComparar({super.key});

  @override
  State<ResultadoComparar> createState() => _ResultadoCompararState();
}

class _ResultadoCompararState extends State<ResultadoComparar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resultados de la PokeComparación',
          style: TextStyles.bodyText,
        ),
        backgroundColor: AppColors.backgroundComponentSelected,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(),
    );
  }
}
