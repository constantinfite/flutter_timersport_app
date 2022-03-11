import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DataBaseConnection {
  setDatabaseExercice() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'db_exercicelist_sqflite');
    var database = await openDatabase(path,
        version: 1, onCreate: _onCreatingDatabaseExercice);
    return database;
  }

  _onCreatingDatabaseExercice(Database database, int version) async {
    await database.execute(
        "CREATE TABLE exercices(id INTEGER PRIMARY KEY, name TEXT, serie INTEGER, repetition INTEGER, resttime INTEGER, exercicetime INTEGER, mode TEXT, color INTEGER, preparationtime INTEGER)");
  }

  setDatabaseEvent() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'db_eventlist_sqflite');
    var database = await openDatabase(path,
        version: 1, onCreate: _onCreatingDatabaseEvent);
    return database;
  }

  _onCreatingDatabaseEvent(Database database, int version) async {
    await database.execute(
        "CREATE TABLE events(id INTEGER PRIMARY KEY, name TEXT, datetime INTEGER, resttime INTEGER, exercicetime INTEGER, totaltime INTEGER)");
  }
}
