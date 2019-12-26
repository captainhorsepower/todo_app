import 'package:todo_chunks/model/repository/repo_provider.dart';

import '../repository/task_repository.dart';
import '../task.dart';

// TODO: make use of transactions for rollbacks
class TaskService {
  TaskRepository taskRepo = RepositoryProvider.instance.taskRepo;

  Future<Task> saveRoot(Task task) async {
    task = await taskRepo.save(task);
    await taskRepo.insertAsRoot(task);
    return task;
  }

  Future<Task> saveChild(Task task, Task parent) async {
    task = await taskRepo.save(task);

    final parentToRootMap = await taskRepo.getPathToRoot(parent.id);
    final taskToRootMap = parentToRootMap
        .map((map) => <String, dynamic>{
              'id': task.id,
              'parent_id': map['parent_id'],
              'direct_parent_id': parent.id,
              'relative_depth': map['relative_depth'] + 1,
            })
        .toList()
          ..add(<String, dynamic>{
            'id': task.id,
            'parent_id': task.id,
            'direct_parent_id': parent.id,
            'relative_depth': 0
          });

    await taskRepo.insertAsChild(taskToRootMap);

    return task;
  }

  Future<Task> update(Task task) async {
    task = await taskRepo.update(task);
    return task;
  }

  Future<void> deleteWithKids(Task task) async {
    await taskRepo.delete(task);
  }

  Future<List<Task>> loadAllRoots() {
    return taskRepo.findAllRoots(depth: 2);
  }

  Future<Task> loadById(int id, int depth) {
    return taskRepo.findById(id, depth);
  }

  Future<void> moveToRoot(Task subtree) async {
    return taskRepo.splitForest(subtree.id);
  }

  Future<void> moveToParent(Task subtree, Task newParent) async {
    assert(subtree.id != newParent.id);

    subtree = await taskRepo.findById(subtree.id, 0);
    newParent = await taskRepo.findById(newParent.id, 0);

    if (subtree == null || newParent == null) {
      throw 'subtree=$subtree, newParent=$newParent';
    }

    if (subtree.isDone ^ newParent.isDone) {
      throw 'sbtr.isDone=${subtree.isDone} & nprnt.isDone=${newParent.isDone}';
    }

    await taskRepo.splitForest(subtree.id);
    await taskRepo.joinForest(subtree.id, newParent.id);
  }
}
