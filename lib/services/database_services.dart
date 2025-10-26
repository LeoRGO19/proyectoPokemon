import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:pokedex/data/pokemon.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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

  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
    print("Base de datos borrada");
  }
}
