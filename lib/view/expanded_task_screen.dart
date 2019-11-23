import 'package:flutter/material.dart';
import 'package:todo_chunks/model/controller/controller_provider.dart';
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
  Task task;
  final taskController = ControllerProvider.instance.taskController;

  @override
  void initState() {
    _updateTask();
    super.initState();
  }

  _updateTask() async {
    final loaded = await taskController.loadById(widget.task.id);
    setState(() => this.task = loaded);
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
              final updatedTask = await Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => CreateTaskScreen(
                    task: this.task,
                  ),
                ),
              );

              if (updatedTask != null) {
                taskController.update(updatedTask);
                _updateTask();
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
                await taskController.deleteWithKids(task);
                Navigator.pop(context);
              }
            },
          ),
        ],
        title: Text('Expanded task screen'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: task == null ? CircularProgressIndicator() : TaskView(task),
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
                                    builder: (context) => ExpandedTaskScreen(task: task),
                                  ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0),
                              child: TaskView(task),
                            )))
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
      await taskController.create(task: newTask, parent: this.task);
      _updateTask();
    }
  }
}
