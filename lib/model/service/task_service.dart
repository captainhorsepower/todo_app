import '../repository/task_repository.dart';
import '../task.dart';

// TODO: make use of transactions for rollbacks
class TaskService {
  TasksRepository taskRepo = TasksRepository();

  Future<Task> save(Task task) async {
    print('save new task');

    final parent = task.parent;

    task = (await taskRepo.save(task))..parent = parent;

    print('put task in existion tree');
    if (parent == null) {
      await taskRepo.insertAsNewRoot(task);
    } else {
      // just in case some parents got offloaded from memory
      // I load the whole path. This might cause performance
      // issues in case user creates tree with height=O(n)
      // where n is about 10^8
      // LOL
      final pathToRoot = (await taskRepo.getPathToRoot(parent.id))
          .map((map) => <String, dynamic>{
                'id': task.id,
                'parent_id': map['parent_id'],
                'direct_parent_id': parent.id,
                'relative_depth': map['relative_depth'] + 1,
              })
          .toList();
      pathToRoot.add(<String, dynamic>{
        'id': task.id,
        'parent_id': task.id,
        'direct_parent_id': parent.id,
        'relative_depth': 0,
      });
      await taskRepo.insertInTree(pathToRoot);
    }

    return task;
  }
}
