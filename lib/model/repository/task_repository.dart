import 'package:todo_chunks/model/repository/dao/task_dao.dart';
import 'package:todo_chunks/model/repository/dao/task_tree_closure_dao.dart';
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
        .map(
          (map) =>
              "(${map['id']}, ${map['parent_id']}, ${map['direct_parent_id']}, ${map['relative_depth']})",
        )
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

    // работает корректно только для isDone = false;
    final isDone = false;
    final sql = """
SELECT
  c.${TaskTreeDao.directParentId},
  task.*,
  (
    SELECT
      COALESCE(sum(kid.${TaskDao.durationMins}), 0)
    FROM
      ${TaskDao.tableName} kid
      LEFT JOIN ${TaskTreeDao.tableName} c ON kid.${TaskDao.id} = c.${TaskTreeDao.id}
    WHERE
      c.${TaskTreeDao.parentId} = task.${TaskDao.id}
      AND kid.${TaskDao.isDone} = $isDone
  ) AS ${TaskDao.totalDurationMins}
FROM
  ${TaskDao.tableName} task
  LEFT JOIN ${TaskTreeDao.tableName} c ON task.id = c.id
WHERE
  c.${TaskTreeDao.parentId} 
    IN (SELECT ${TaskTreeDao.id} FROM ${TaskTreeDao.tableName} WHERE ${TaskTreeDao.directParentId} IS NULL)
  AND c.${TaskTreeDao.depth} <= $depth
  AND task.${TaskDao.isDone} = $isDone
""";

    final db = await provider.database;
    final result = await db.rawQuery(sql);

    result.forEach(print);

    final idTaskMap = <int, Task>{};
    result.forEach((taskMap) {
      idTaskMap.putIfAbsent(
        taskMap['${TaskDao.id}'],
        () => taskDao.fromJson(taskMap),
      );
    });

    result.forEach((taskMap) {
      if (taskMap['${TaskTreeDao.directParentId}'] == null) return;

      final task = idTaskMap[taskMap['${TaskDao.id}']];
      final parent = idTaskMap[taskMap['${TaskTreeDao.directParentId}']];

      // FIXME: это потенциально испортит сортировку базой данных
      task.parent = parent;
      parent.subtasks.add(task);
    });

    print('repository: loaded ${idTaskMap.values.length} tasks in total');

    return idTaskMap.values.where((task) => task.parent == null).toList();
  }

  Future<Task> findById(int id, int depth) async {
    print('repo: find with children by id=$id');
    assert(id != null && depth != null);

    final db = await provider.database;

    final result = await db.rawQuery(TaskDao.findTaskAndKidsByIdAndDepth, [id, depth]);

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

  Future<void> splitForest(int subtreeRootId) async {
    print('repo: splitForest, id=$subtreeRootId');

    final db = await provider.database;

    var result =
        await db.rawQuery('SELECT id FROM task_tree_closure WHERE parent_id = ?1', [subtreeRootId]);
    final idLine = result.map((map) => map['id']).join(',');
    print('repo: subtree IDs ($idLine)');

    await db.rawDelete(
        'DELETE FROM task_tree_closure WHERE id in ($idLine) and parent_id not in ($idLine)');
    print('repo: split done');

    await db.rawUpdate(
        'UPDATE task_tree_closure SET direct_parent_id = null WHERE id = ?1', [subtreeRootId]);
    print('repo: made $subtreeRootId root');

    print('repo: splitForest done');
  }

  Future<void> joinForest(int subtreeId, int parentId) async {
    print('repo: joinForest, subtreeId=$subtreeId, parentId=$parentId');

    final db = await provider.database;

    var parentPathToRoot = await getPathToRoot(parentId);
    var kids = await db.rawQuery(
        'SELECT id, direct_parent_id, relative_depth FROM task_tree_closure WHERE parent_id = ?1',
        [subtreeId]);

    print('\nkids=$kids\nparentPathToRoot=$parentPathToRoot');

    List<Map<String, int>> treeStructure = [];
    for (var kid in kids) {
      int id = kid['id'];
      int directParentId = kid['direct_parent_id'];
      int depth = kid['relative_depth'];

      for (var parent in parentPathToRoot) {
        treeStructure.add({
          'id': id,
          'parent_id': parent['parent_id'],
          'direct_parent_id': id == subtreeId ? parentId : directParentId,
          'relative_depth': depth + 1 + parent['relative_depth']
        });
      }
    }

    final insertValues = treeStructure
        .map((map) =>
            "(${map['id']}, ${map['parent_id']}, ${map['direct_parent_id']}, ${map['relative_depth']})")
        .join(", ");

    await db.update(
      'task_tree_closure',
      {'direct_parent_id': parentId},
      where: 'id=$subtreeId and direct_parent_id is null',
    );

    await db.rawInsert('INSERT INTO task_tree_closure '
        '(id, parent_id, direct_parent_id, relative_depth) '
        'values $insertValues');

    print('repo: joinForest done.');
  }

  rawFindAll(String query, [List<dynamic> arguments]) async {
    print('repository: rawQuery');

    final db = await provider.database;

    final result = await db.rawQuery(query, arguments);

    return result;
  }
}
