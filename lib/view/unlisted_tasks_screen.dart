import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../model/controller/task_controller.dart';
import '../model/repository/task_repository.dart';
import '../model/task.dart';
import '../view/expanded_task_screen.dart';
import '../view/task_view.dart';

import 'create_task_screen.dart';

class UnlistedTaskScreen extends StatefulWidget {
  @override
  _UnlistedTaskScreenState createState() => _UnlistedTaskScreenState();
}

class _UnlistedTaskScreenState extends State<UnlistedTaskScreen> {
  List<Task> tasks;

  @override
  void initState() {
    TasksRepository repo = TasksRepository();
    repo.findAllRoots().then((tasks) {
      this.setState(() => this.tasks = tasks);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unlisted Tasks'),
      ),
      body: tasks == null
          ? CircularProgressIndicator()
          : ListView(
              children: tasks.map((task) => _buildListTile(task, context)).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('pressed button');

          await _showCreateTask(context);

          print('button released UI lock');
        },
        tooltip: 'Add new task',
        child: Icon(Icons.add),
      ),
    );
  }

  Future _showCreateTask(BuildContext context) async {
    final task = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CreateTaskScreen(),
      ),
    );

    if (task != null) {
      final controller = TaskController();
      controller.createNewTask(task).then((saved) {
        TasksRepository repo = TasksRepository();
        repo.findAllRoots().then((tasks) {
          this.setState(() => this.tasks = tasks);
        });
      });
    }
  }

  Widget _buildListTile(Task task, BuildContext context) {
    return ExpansionTile(
      title: TaskView(task),
      children: task.subtasks
          .map((task) => GestureDetector(
              child: TaskView(task),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpandedTaskScreen(task: task)),
                );
              }))
          .toList(),
    );
  }
}
