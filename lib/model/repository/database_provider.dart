import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final databaseFileName = 'todo_chunks.db';

  static final OnDatabaseConfigureFn onConfigureFn = (db) async {
    print('onCofigure for database ${db.path}');

    // enable foreign keys (disabled by default)
    print('enable foreign keys');
    // await db.execute('PRAGMA foreign_keys = OFF');

    print('create closure table');
    await db.execute('''
CREATE TABLE IF NOT EXISTS task_tree_closure (
  id INTEGER NOT NULL REFERENCES tasks (id),
  parent_id INTEGER NOT NULL REFERENCES tasks (id),
  direct_parent_id INTEGER REFERENCES tasks (id),
  relative_depth INTEGER NOT NULL,
  PRIMARY KEY (id, parent_id),
  CHECK(
    (
      id == parent_id
      AND relative_depth == 0
    )
    OR (
      id != parent_id
      AND direct_parent_id != id
      AND relative_depth > 0
    )
  )
)
''');

    print('create tasks table');
    await db.execute('''
CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER,
  title TEXT NOT NULL,
  duration_mins INT NOT NULL DEFAULT 30,
  created_at TEXT NOT NULL,
  due_to TEXT,
  is_done BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id),
  CHECK(duration_mins > 0)
)
''');

    print('onConfigure finished');
  };

  static DatabaseProvider _instance = DatabaseProvider._internal();

  Database _database;

  String _path;

  DatabaseProvider._internal();

  static DatabaseProvider get instance => _instance;

  Future<Database> get database async {

    if (_database == null) {
      await _init();
    }

    return _database;
  }

  _init() async {
    if (_path == null) {
      print('get database path');
      _path = await getDatabasesPath();
      _path = join(_path, databaseFileName);
    }
    print('path=$_path');

    print('open database');

    _database = await openDatabase(
      _path,
      onConfigure: onConfigureFn,
    );

    print('success');
  }
}
