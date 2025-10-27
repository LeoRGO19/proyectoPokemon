// exceptions.dart
// Cada Exception cuenta con un Mensaje Especifico para que cuando salten, se sepa por que ocurren.

// exception para saltar cuando la api se encuentre offline

class ApiOfflineException implements Exception {
  final String message;
  ApiOfflineException([this.message = "No se pudo conectar con la API."]);

  @override
  String toString() => "ApiOfflineException: $message";
}

// exception para falla de conexion local
class NoConnectionException implements Exception {
  final String message;
  NoConnectionException([this.message = "Sin conexión a Internet."]);

  @override
  String toString() => "NoConnectionException: $message";
}

// exception para pokemon con informacion nula
class NullPokemonException implements Exception {
  final String message;
  NullPokemonException([this.message = "No se encontró el Pokémon."]);
}
