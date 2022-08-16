import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


final DATABASE_NAME = "barcode.db";
final TABLE_NAME = "barcode-query-results";
var col_MATERIAL = "material";
var col_NOME = "nome";
var col_CODIGO = "codigo";
var col_SET = "cod_set";

class DatabaseHelper {

  static final columnId = '_id';
  static final columnNome = 'nome';
  static final columnIdade = 'idade';

  // torna esta classe singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  // // tem somente uma referência ao banco de dados
  // static Database? _database;

  Future<Database?> get database async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();

      var databaseFactory = databaseFactoryFfi;
      var databasesPath = await databaseFactory.getDatabasesPath();
      var path = join(databasesPath, "barcode-barcode.db");
      print(databasesPath);

      // Verifica se a database existe
      var exists = await databaseExists(path);

      if (!exists) {
        // Should happen only the first time you launch your application
        print("Creating new copy from asset");


        // Make sure the parent directory exists
        try {
          await Directory(dirname(path)).create(recursive: true);
        } catch (_) {}

        // Copy from asset
        ByteData data = await rootBundle.load(
            join("assets", "barcode-barcode.db"));
        List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        // Write and flush the bytes written
        await File(path).writeAsBytes(bytes, flush: true);
      } else {
        print("Opening existing database");
        print("from desktop");
      }

// open the database
      var db = await databaseFactory.openDatabase(path);
      return db;
    }


    if (Platform.isAndroid || Platform.isIOS) {
      var databasesPath = await getDatabasesPath();
      var path = join(databasesPath, "barcode.db");
      print(databasesPath);

      // Verifica se a database existe
      var exists = await databaseExists(path);

      if (!exists) {
        // Should happen only the first time you launch your application
        print("Creating new copy from asset");


        // Make sure the parent directory exists
        try {
          await Directory(dirname(path)).create(recursive: true);
        } catch (_) {}

        // Copy from asset
        ByteData data = await rootBundle.load(
            join("assets", "barcode-barcode.db"));
        List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        // Write and flush the bytes written
        await File(path).writeAsBytes(bytes, flush: true);
      } else {
        print("Opening existing database");
        print("From smartphone");
      }

// open the database
      var db = await openDatabase(path,readOnly: true);
      return db;
    }
  }

  Future<int?> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db?.insert(TABLE_NAME, row);
  }
  Future<bool?> read() async {
    Database? db = await instance.database;
    return await db?.isOpen;
  }
  // Todas as linhas são retornadas como uma lista de mapas, onde cada mapa é
  // uma lista de valores-chave de colunas.
  Future<List<Map<String, dynamic>>?> queryAllRows() async {
    Database? db = await instance.database;
    return await db?.query(TABLE_NAME);
  }
  // Todos os métodos : inserir, consultar, atualizar e excluir,
  // também podem ser feitos usando  comandos SQL brutos.
  // Esse método usa uma consulta bruta para fornecer a contagem de linhas.
  Future<int?> queryRowCount(String codigo) async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(await db!.rawQuery('SELECT COUNT(*) FROM "$TABLE_NAME" where "$col_CODIGO" = "${codigo.trim()}" or "$col_MATERIAL" = "${codigo.trim()}"'));
  }

  // Future<int?> update(Map<String, dynamic> row) async {
  //   Database? db = await instance.database;
  //   int id = row[columnId];
  //   return await db?.update(TABLE_NAME, row, where: '$columnId = ?', whereArgs: [id]);
  // }
  // Exclui a linha especificada pelo id. O número de linhas afetadas é
  // retornada. Isso deve ser igual a 1, contanto que a linha exista.
  // Future<int?> delete(int id) async {
  //   Database? db = await instance.database;
  //   return await db?.delete(TABLE_NAME, where: '$columnId = ?', whereArgs: [id]);
  // }
}