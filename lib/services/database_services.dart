import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:math';
//Base de datos que almacena todos los pokemon que se piden a la pokeapi al ejecutar la pokedex por primera vez
//Esto permite que después de su primera ejecución los pokémon cargen de forma casi intantánea

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance =
      DatabaseService._constructor(); //singleton
  //definimos nombres en tabla
  final String _pokemonTableName = "Pokemon";
  final String _pokemonIdColumnName = "id";
  final String _pokemonNameColumnName =
      "name"; //esto estará marcado como unique para que no haya pokemon repetidos
  final String _pokemonUrlColumnName = "url";
  final String _pokemonTypesColumnName = "types";
  final String _pokemonGenColumnName = "generation";
  final String _pokemonLegendColumnName = "isLegendary";
  final String _pokemonMythColumnName = "isMythical";
  final String _pokemonColorColumnName = "color";
  final String _pokemonHabitatColumnName = "habitat";
  final String _pokemonShapeColumnName = "shape";
  final String _pokemonEggColumnName = "eggGroups";

  DatabaseService._constructor();
  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database = await openDatabase(
      databasePath,
      //creamos tabla
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_pokemonTableName(
          $_pokemonIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
          $_pokemonNameColumnName TEXT NOT NULL UNIQUE,  
          $_pokemonUrlColumnName TEXT NOT NULL,
          $_pokemonTypesColumnName TEXT NOT NULL,
          $_pokemonGenColumnName TEXT NOT NULL,
          $_pokemonLegendColumnName INTEGER,
          $_pokemonMythColumnName INTEGER,
          $_pokemonColorColumnName TEXT NOT NULL,
          $_pokemonHabitatColumnName TEXT,
          $_pokemonShapeColumnName TEXT,
          $_pokemonEggColumnName TEXT NOT NULL
        )
        ''');
      },
      version: 1,
    );
    return database;
  }

  //metodo que transforma cada pokemon de la lista en un map y luego esa lista también, para poder guardar adecuadamente en tabla
  void addPokemon(List<Pokemon> pokemon) async {
    final db = await database;
    for (var pok in pokemon) {
      await db.insert(
        _pokemonTableName,
        pok.toMap(),
        conflictAlgorithm:
            ConflictAlgorithm.replace, //reemplaza si encuentra datos
      );
    }
  }

  //pasa de map a lista y luego crea los pokemon
  Future<List<Pokemon>> getPokemon() async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query(_pokemonTableName);
    return List.generate(data.length, (i) {
      return Pokemon.fromMap(data[i]);
    });
  }

  //chequea que los 1025 pokémon que mostramos se hayan cargado correctamente
  Future<int> checkData() async {
    const expectedCount = 1025;
    final db = await database;

    final countResult = await db.rawQuery(
      'SELECT COUNT(DISTINCT name) AS count FROM $_pokemonTableName',
    );
    final int actualCount = Sqflite.firstIntValue(countResult) ?? 0;

    if (actualCount != expectedCount) {
      print(
        'Database incompleta: $actualCount / $expectedCount Pokémon guardados.',
      );
      //await clearTable(_pokemonTableName); // vacía la tabla
      return actualCount;
    }

    print('Todos los $actualCount Pokémon fueron guardados exitosamente!');
    return actualCount;
  }

  Future<void> loadInitialData(
    Future<List<Pokemon>> Function(int offset, int limit) fetcher,
  ) async {
    // Solo se ejecuta si la DB está incompleta
    if (await checkData() < 1025) {
      print('Iniciando carga COMPLETA de 1025 Pokémon en batches de 50...');
      const totalPokemon = 1025;
      const batchSize = 50;
      int savedCount = await checkData(); // Revisa cuántos ya están guardados
      int offset =
          (savedCount ~/ batchSize) *
          batchSize; // Calcula el offset para reanudar desde el último batch completo

      try {
        if (offset > 0) {
          print('Reanudando carga desde el offset: $offset');
        }

        while (offset < totalPokemon) {
          int limit = min(batchSize, totalPokemon - offset);
          if (limit <= 0) break;

          // 1. Obtener batch de Pokémon CON DETALLES, con reintentos
          List<Pokemon> batch = [];
          int fetchRetries = 0;
          bool fetchSuccess = false;
          while (!fetchSuccess && fetchRetries < 4) {
            try {
              batch = await fetcher(offset, limit);
              fetchSuccess = true;
            } catch (e) {
              fetchRetries++;
              print(
                'Error al obtener batch en offset $offset (intento $fetchRetries): $e',
              );
              if (fetchRetries >= 4) {
                print(
                  'Se omitió definitivamente el batch en offset $offset tras 4 intentos fallidos.',
                );
                break;
              } else {
                await Future.delayed(Duration(milliseconds: 800));
              }
            }
          }
          if (!fetchSuccess) {
            offset += limit;
            continue;
          }

          // 2. Guardar batch en la DB, con reintentos por cada Pokémon
          for (var pok in batch) {
            int retries = 0;
            bool success = false;
            while (!success && retries < 4) {
              try {
                addPokemon([pok]);
                success = true;
              } catch (e) {
                retries++;
                print('Error al guardar ${pok.name} (intento $retries): $e');
                if (retries >= 4) {
                  print(
                    'Se omitió definitivamente a ${pok.name} tras 4 intentos fallidos.',
                  );
                } else {
                  await Future.delayed(Duration(milliseconds: 500));
                }
              }
            }
          }

          offset += limit;
          savedCount = await checkData(); // Actualiza el conteo real
          print(
            'Guardados $savedCount de $totalPokemon Pokémon en DB. Último: batch.isNotEmpty ? batch.last.name : "(ninguno)"}',
          );
        }
        print('Carga inicial completa y guardada en la base de datos.');

        // Si no se llegó a 1025, reintentar en segundo plano
        int finalCount = await checkData();
        if (finalCount < 1025) {
          print(
            'Faltan ${1025 - finalCount} Pokémon. Iniciando reintentos automáticos en segundo plano...',
          );
          Future(() async {
            int retry = 0;
            const int maxRetries = 30; // Por ejemplo, 30 intentos
            while (retry < maxRetries) {
              await Future.delayed(
                Duration(seconds: 30),
              ); // Espera 30 segundos entre intentos
              int count = await checkData();
              if (count >= 1025) {
                print('¡Base de datos completada en reintentos automáticos!');
                break;
              }
              print(
                'Reintento automático #${retry + 1}: Faltan ${1025 - count} Pokémon.',
              );
              await loadInitialData(fetcher); // Reintenta cargar los faltantes
              retry++;
            }
            if (await checkData() < 1025) {
              print(
                'No se logró completar la base de datos tras $maxRetries reintentos automáticos.',
              );
            }
          });
        }
      } catch (e) {
        print('Error grave durante la carga inicial de Pokémon: $e');
        // No rethrow para no bloquear el inicio de la app.
      }
    } else {
      print('Base de datos completa (1025 Pokémon). No se requiere carga.');
    }
  }

  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
    print("Base de datos borrada");
  }

  Future<void> clearAllPokemon() async {
    final db = await database;
    await db.delete(_pokemonTableName);
    print("Base de datos de Pokémon borrada");
  }
}
