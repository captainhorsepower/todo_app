import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_chunks/model/repository/dao/task_dao.dart';

class DatabaseProvider {
  static final databaseFileName = 'todo_chunks.db';

  static final OnDatabaseConfigureFn onConfigureFn = (db) async {
    print('onCofigure for database ${db.path}');

    // enable foreign keys (disabled by default)
    await db.execute('PRAGMA foreign_keys = ON;');

    print('onConfigure finished');
  };

  static final OnDatabaseCreateFn onCreateFn = (db, _) async {
    print('onCreate for database with path ${db.path}');

    // create table for tasks
    await db.execute(TaskDao.createTableQuery);

    print('onCreate finished');
  };

  static DatabaseProvider _instance = DatabaseProvider._internal();

  Database _database;

  String _path;

  DatabaseProvider._internal();

  static DatabaseProvider get instance => _instance;

  Future<Database> get database async {

    print('get database called');
    
    _path ??= await getDatabasesPath();

    _path = join(_path, databaseFileName);

    print('attemtinp to open database');
    try {
    _database ??= await openDatabase(
      _path,
      version: 1,
      onConfigure: onConfigureFn,
      onCreate: onCreateFn,
    );
    } catch (e, st) {
      _database = null;
      print(st);
    } 

    print('success');
    
    return _database;
  }
}
