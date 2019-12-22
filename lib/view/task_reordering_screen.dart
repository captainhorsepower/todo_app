import 'package:flutter/material.dart';
import 'package:todo_chunks/model/repository/repo_provider.dart';
import 'package:todo_chunks/model/repository/task_repository.dart';

class TaskReorderingView extends StatelessWidget {
  final task;
  final taskRepo = RepositoryProvider.instance.taskRepo;

  TaskReorderingView({Key key, this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxDepth = taskRepo.rawFindAll(
        'SELECT id, MAX(relative_depth) as depth FROM task_tree_closure WHERE id = ?1', [task.id]);
    return SafeArea(
      child: Container(
        child: MaterialButton(
          child: FutureBuilder(
            future: maxDepth,
            builder: (_, snapshot) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('maxDepth=${snapshot.data?.toString() ?? '?'}'),
                  ...List.generate(
                    1 + (snapshot.data?.first['depth'] ?? 0),
                    (i) => _updateDepth(i),
                  ),
                ],
              );
            },
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _updateDepth(int i) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: MaterialButton(
        child: Text('depth $i', textScaleFactor: 1.3),
        onPressed: () async {
          // taskRepo.rawFindAll('query')
        }
      ),
    );
  }
}
