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
    // db.ins

    print('got results!');
    result.forEach(print);
  }

  @override
  Future<Task> save(Task task) async {
    final db = await provider.database;

    print('create task');

    task.id = await db.insert(TaskDao.tableName, taskDao.toJson(task));

    print('task created, id = ${task.id}');

    // task is root
    if (task.parent == null) {
      db.insert('task_tree_closure', <String, dynamic>{
        'id': task.id,
        'parent_id': task.id,
        'relative_depth': 0,
      });
    }
    // task is not root
    else {
      // FIXME: insert all by one query
      var parent = task;
      var depth = 0;
      while (parent != null) {
        print('task.id=${task.id}, parent.id=${parent.id}, depth=$depth');
        db.insert('task_tree_closure', <String, dynamic>{
          'id': task.id,
          'direct_parent_id': task.parent.id,
          'parent_id': parent.id,
          'relative_depth': depth,
        });
        depth++;
        parent = parent.parent;
      }
    }

    print('inserted task in the tree');

    return task;
  }

  @override
  Future<Task> findById(int id) async {
    print('find by id = $id');

    final db = await provider.database;

    final result = await db.rawQuery(TaskDao.findTaskByIdQuery, [id]);

    print('got results: $result');

    return taskDao.fromJson(result.first);
  }

  Future<Task> findWithChildrenById(int id, int depth) async {
    print('find with children by id=$id');

    final db = await provider.database;

    final result = await db.rawQuery(TaskDao.findTaskAndKidsByIdAndDepth, [id, depth]);

    print('got results: $result');

    final idTaskMap = <int, Task>{};
    result.forEach((taskMap) {
      idTaskMap.putIfAbsent(taskMap['id'], () => taskDao.fromJson(taskMap));
    });

    result.forEach((taskMap) {
      if (taskMap['direct_parent_id'] == null) return;
      if (taskMap['id'] == id) return;
      final task = idTaskMap[taskMap['id']];
      final parent = idTaskMap[taskMap['direct_parent_id']];

      task.parent = parent;
      parent.subtasks.add(task);

    });

    return idTaskMap[id];
  }

  @override
  Future<Task> update(Task task) async {
    print('update task id=${task.id}');

    final db = await provider.database;

    int result = await db.update(
      TaskDao.tableName,
      taskDao.toJson(task),
      where: '${TaskDao.id} = ?',
      whereArgs: [task.id],
    );

    print('result = $result');

    return task;
  }

  // FIXME: delete rows from closure table, or use cascade
  Future<void> delete(Task task) async {
    print('delete task $task');

    final db = await provider.database;

    int result = await db.delete(
      TaskDao.tableName,
      where: '${TaskDao.id} = ?',
      whereArgs: [task.id],
    );

    print('result = $result');
  }
}
