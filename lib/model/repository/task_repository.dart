import 'package:todo_chunks/model/repository/dao/task_dao.dart';
import 'package:todo_chunks/model/repository/database_provider.dart';

import '../task.dart';

class TaskRepository {
  final DatabaseProvider provider = DatabaseProvider.instance;
  final TaskDao taskDao = TaskDao();

  Future<Task> save(Task task) async {
    print('repository: save task');

    final db = await provider.database;
    final generatedId = await db.insert(TaskDao.tableName, taskDao.toJson(task));
    task = task.copyWith(id: generatedId);

    print('repository: saved, task.id = $generatedId');

    return task;
  }

  Future<void> insertAsChild(List<Map<String, dynamic>> pathToRoot) async {
    print('repository: insert task in the tree');

    final String insertValues = pathToRoot
        .map((map) =>
            "(${map['id']}, ${map['parent_id']}, ${map['direct_parent_id']}, ${map['relative_depth']})")
        .join(", ");

    final db = await provider.database;
    await db.rawInsert('INSERT INTO task_tree_closure '
        '(id, parent_id, direct_parent_id, relative_depth) '
        'values $insertValues');

    print('repository: task inserted.');
  }

  Future<void> insertAsRoot(Task task) async {
    print('repository: insert task as root');

    final db = await provider.database;
    await db.insert('task_tree_closure', <String, dynamic>{
      'id': task.id,
      'parent_id': task.id,
      'relative_depth': 0,
    });

    print('repository: created new root, id=${task.id}');
  }

  Future<List<Map<String, dynamic>>> getPathToRoot(int id) async {
    print('get path to the root, id=$id');

    final db = await provider.database;
    final path = await db.query(
      'task_tree_closure',
      columns: ['parent_id', 'relative_depth'],
      where: 'id = ?1',
      whereArgs: [id],
    );

    print('got path.');
    return path;
  }

  Future<List<Task>> findAllRoots({int depth = 1}) async {
    print('repository: find all roots');

    final db = await provider.database;
    final result = await db.rawQuery(TaskDao.findRootsAndKidsAtDepth, [depth]);

    final idTaskMap = <int, Task>{};
    result.forEach((taskMap) {
      idTaskMap.putIfAbsent(taskMap['id'], () => taskDao.fromJson(taskMap));
    });

    result.forEach((taskMap) {
      if (taskMap['direct_parent_id'] == null) return;
      final task = idTaskMap[taskMap['id']];
      final parent = idTaskMap[taskMap['direct_parent_id']];

      task.parent = parent;
      parent.subtasks.add(task);
    });

    return idTaskMap.values.where((task) => task.parent == null).toList();
  }

  Future<Task> findById(int id, int depth) async {
    print('find with children by id=$id');
    assert(id != null && depth != null);

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

  Future<void> delete(Task task) async {
    print('repository: delete task with all kids');

    final db = await provider.database;

    final result =
        await db.rawQuery('select id from task_tree_closure where parent_id = ?1', [task.id]);
    final ids = result.map((map) => map['id']).toList();
    final inRangeStr = '(${ids.join(', ')})';

    print('tasks in range $inRangeStr will be deleted.');

    // delete all from task_tree_closure
    await db.rawDelete('delete from task_tree_closure where id IN $inRangeStr');

    // delete tasks
    final deletedCount = await db.rawDelete('delete from tasks where id IN $inRangeStr');

    print('repository: deleted $deletedCount tasks.');
  }
}
