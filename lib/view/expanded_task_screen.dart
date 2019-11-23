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
  TasksRepository taskRepo = TasksRepository();
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
        title: Text('Expanded task screen'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: TaskView(widget.task),
          ),
          Container(
            height: 400,
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
    final task = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CreateTaskScreen(),
      ),
    );

    if (task != null) {
      task.parent = this.task;

      final controller = TaskController();
      controller.createNewTask(task).then((saved) {
        TasksRepository repo = TasksRepository();
        repo.findWithChildrenById(task.id, 2).then((task) {
          this.setState(() => this.task = task);
        });
      });
    }
  }
}
