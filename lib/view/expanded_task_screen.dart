import 'package:flutter/material.dart';
import 'package:todo_chunks/model/controller/task_controller.dart';
import 'package:todo_chunks/model/repository/task_repository.dart';
import 'package:todo_chunks/view/task_view.dart';

import '../model/task.dart';
import 'create_task_screen.dart';

class ExpandedTaskScreen extends StatefulWidget {
  final Task task;

  const ExpandedTaskScreen({Key key, this.task}) : super(key: key);

  @override
  _ExpandedTaskScreenState createState() => _ExpandedTaskScreenState();
}

class _ExpandedTaskScreenState extends State<ExpandedTaskScreen> {
  TaskRepository taskRepo = TaskRepository();
  Task task;

  @override
  void initState() {
    () async {
      task = await taskRepo.findWithChildrenById(widget.task.id, 2);
      setState(() {});
    }();

    print('expanded screen init state');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          // FIXME: UI is not updated properly.
          IconButton(
            icon: Icon(Icons.create),
            onPressed: () async {
              final task = await Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => CreateTaskScreen(
                    task: this.task,
                  ),
                ),
              );

              if (task != null) {
                final repo = TaskRepository();
                await repo.update(task);
                final updated = await repo.findWithChildrenById(task.id, 2);
                setState(() {
                  this.task = updated;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              bool res = await showDialog(
                context: context,
                builder: (context) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        'Confirm',
                        textScaleFactor: 3,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                    FlatButton(
                      child: Text(
                        'Cancel',
                        textScaleFactor: 3,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );

              res ??= false;

              if (res) {
                final controller = TaskController();
                await controller.deleteWithKids(task);
                setState(() {});
              }
            },
          ),
        ],
        title: Text('Expanded task screen'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: TaskView(widget.task),
          ),
          Expanded(
            flex: 1,
            child: task == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    children: task.subtasks
                        .map((task) => GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ExpandedTaskScreen(task: task)));
                            },
                            child: TaskView(task)))
                        .toList()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showCreateTask(context);
        },
        tooltip: 'Add new task',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreateTask(BuildContext context) async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CreateTaskScreen(),
      ),
    );

    if (newTask != null) {
      final controller = TaskController();
      await controller.create(task: newTask, parent: this.task);
    }
  }
}
