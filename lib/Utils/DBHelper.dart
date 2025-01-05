
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'Constants.dart';

class DBHelper {
  static Database? _database;
  static final DBHelper instance = DBHelper.privateConstructor();

  DBHelper.privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);
    print('DB Path:'+path);
    // Check if the database already exists
    final isExist = await databaseExists(path);
    if (!isExist) {
      print('Database not exisit');
      // await _createDatabase(path);
       _createDatabase(path);
    }
    else{
      print('Database exisit');
    }

    // Open the database
    return await openDatabase(path);
  }



  void _createDatabase(String path) async {
    print('testDatabase Created 1');
    final db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {


          await db.execute('''
        CREATE TABLE IF NOT EXISTS '''+tableName+''' (
          id INTEGER PRIMARY KEY,
          name TEXT,
          udate TEXT,
          startTime1 Text,
          endTime1 Text,
          startTime2 Text,
          endTime2 Text,
          startTime3 Text,
          endTime3 Text,
          startTime4 Text,
          endTime4 Text,
          startTime5 Text,
          endTime5 Text,
          startTime6 Text,
          endTime6 Text,
          startTime7 Text,
          endTime7 Text,
          startTime8 Text,
          endTime8 Text,
          startTime9 Text,
          endTime9 Text,
          startTime10 Text,
          endTime10 Text
        )
      ''');

        });
    print('testDatabase Created 2');
    // return db.close();
  }


  Future<int> insert(Map<String, dynamic> row) async {
    final db = await instance.database;
    bool tableExists = await isTableExists(tableName, db);
    if (!tableExists) {
      await createTableIfNotExists(db);
    }


    return await db.insert(tableName, row);
  }

  Future<bool> isTableExists(String tableName, Database db) async {
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName';",
    );
    return result.isNotEmpty;
  }

  Future<void> createTableIfNotExists(Database db) async {
    await db.execute('''
   CREATE TABLE IF NOT EXISTS '''+tableName+''' (
          id INTEGER PRIMARY KEY,
          name TEXT,
          udate TEXT,
          startTime1 Text,
          endTime1 Text,
          startTime2 Text,
          endTime2 Text,
          startTime3 Text,
          endTime3 Text,
          startTime4 Text,
          endTime4 Text,
          startTime5 Text,
          endTime5 Text,
          startTime6 Text,
          endTime6 Text,
          startTime7 Text,
          endTime7 Text,
          startTime8 Text,
          endTime8 Text,
          startTime9 Text,
          endTime9 Text,
          startTime10 Text,
          endTime10 Text
        )
  ''');
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await instance.database;
    return await db.query(tableName);
  }


  Future<int> update(Map<String, dynamic> row,int id) async {
    final db = await instance.database;

    return await db.update(tableName, row, where: 'id = ?', whereArgs: [id]);
  }


  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTable()async {
    final db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  Future<void> deleteMasterTable()async {
    final db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS $tableNameMasterData');
  }

  deletDatabase()async{
  var documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, dbName);

  Database db = await openDatabase(path);
  await db.transaction((txn) async {
    await txn.rawDelete('DELETE FROM '+tableName);
  });

  // await deleteDatabase(path);
  // _initDatabase();
}


  Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
    // Open database
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, dbName);
    print('DBPath+'+dbPath);
    Database db = await openDatabase(dbPath);

    // Get data from your table
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT * FROM '+tableName);

    // Close database
    await db.close();

    return result;
  }


  Future<List<Map<String, dynamic>>> queryRecordsFilter(String columnName, String value) async {
    print('queryedColumnName:'+columnName);
    print('queryedValue:'+value);
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, dbName);

    Database db = await openDatabase(dbPath);
    var d= await db.query(tableName,
        where: '$columnName = ?',
        whereArgs: [value]);

    d.forEach((row) {
      print(row);
    });

    // Close the database

    return d;
  }


}
