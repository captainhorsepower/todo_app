import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todo_chunks/model/controller/controller_provider.dart';

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

  final taskController = ControllerProvider.instance.taskController;

  @override
  void initState() {
    _updateTasks();
    super.initState();
  }

  _updateTasks() {
    taskController.loadAllRoots().then((tasks) => setState(() => this.tasks = tasks));
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
      await taskController.create(task: task);
      _updateTasks();
    }
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
