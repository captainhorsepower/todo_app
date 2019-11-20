import 'package:sqflite/sqlite_api.dart';
import 'package:todo_chunks/model/repository/dao/task_dao.dart';
import 'package:todo_chunks/model/repository/database_provider.dart';
import 'package:todo_chunks/model/repository/repository.dart';

import '../task.dart';

class TasksRepository implements Repository<Task, int> {

  final DatabaseProvider provider = DatabaseProvider.instance;
  final TaskDao taskDao = TaskDao();


  doQuery(String query) async {

    print('hello from repo');
    final Database db = await provider.database;

    print('recieved database');

    print('executing query: \n$query');
    final result = await db.rawQuery(query);
  
    print('got results!');
    result.forEach(print);
  }

  @override
  @override
  Future<Task> save(Task entity) async {
    final db = await provider.database;
    entity.id = await db.insert(TaskDao.tableName, taskDao.toJson(entity));
    return entity;
  }

  @override
  Future<Task> update(Task entity) {
    // TODO: implement update
    return null;
  }

  @override
  Future<Task> findById(int id) {
    // TODO: implement findById
    return null;
  }


  Future<void> delete(Task entity) {
    // TODO: implement delete
    return null;
  }



}
