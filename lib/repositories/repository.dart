import 'package:sport_timer/repositories/database_connection.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  DataBaseConnection? _dataBaseConnection;

  Repository() {
    //Initialize database  connection
    _dataBaseConnection = DataBaseConnection();
  }

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _dataBaseConnection?.setDatabase();
    return _database!;
  }

  insertData(table, data) async {
    var connection = await database;
    return await connection.insert(table, data);
  }

  //Read data from Table
  readData(table) async {
    var connection = await database;
    return await connection.query(table);
  }

  //Read data from Table by Id
  readDataById(table, itemId) async {
    var connection = await database;
    return await connection.query(table, where: 'id=?', whereArgs: [itemId]);
  }
}
