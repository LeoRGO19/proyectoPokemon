import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pokedex/exceptions/exceptions.dart';

class ExceptionHandler {
  // Navigator key para los dialogs, aun en proceso
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static String handle(Object error) {
    log("Error detectado: $error");

    String title = "Error";
    String message = "Ocurrio un error.";

    // logs extras, por si acaso.
    if (error is ApiOfflineException) {
      title = "ApiOffline";
      message = "La API no se encuentra disponible.";
      debugPrint("API sin conexión");
    } else if (error is NoConnectionException) {
      title = "NoConnection";
      message = "Revisa tu conexion a Internet.";
      debugPrint("Sin conexión a internet");
    } else if (error is NullPokemonException) {
      title = "NullPokemon";
      message = "Error al crear el Pokémon.";
      debugPrint("Error al recibir datos de Pokemon");
    } else if (error is SocketException || error is ClientException) {
      title = "NoConnection";
      message = "Revisa tu conexion a Internet.";
      debugPrint("Sin conexión a internet");
    }

    return message;
    //_showErrorDialog(title, message);
  }

  /*static void _showErrorDialog(String title, String message) {
    final context = navigatorKey.currentState?.overlay?.context;
    if (context == null) {
      debugPrint("No hay context");
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }*/
}
