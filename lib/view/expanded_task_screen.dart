import 'package:flutter/material.dart';

import '../model/controller/controller_provider.dart';
import '../model/task.dart';
import 'create_task_screen.dart';
import 'task_view.dart';

class ExpandedTaskScreen extends StatefulWidget {
  final Task task;

  const ExpandedTaskScreen({Key key, this.task}) : super(key: key);

  @override
  _ExpandedTaskScreenState createState() => _ExpandedTaskScreenState();
}

class _ExpandedTaskScreenState extends State<ExpandedTaskScreen> {
  final taskController = ControllerProvider.instance.taskController;

  @override
  Widget build(BuildContext context) {
    final taskFuture = taskController.loadById(widget.task.id, depth: 2);

    var taskHolder = widget.task;
    taskFuture.then((task) => taskHolder = task);

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.create),
            onPressed: () async {
              final updatedTask = await Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => CreateTaskScreen(task: taskHolder),
                ),
              );

              if (updatedTask != null) {
                await taskController.update(updatedTask);
                setState(() {});
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              bool deleteFlag = await showDialog(
                context: context,
                builder: (context) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Delete', textScaleFactor: 3),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                    FlatButton(
                      child: Text('Mercy', textScaleFactor: 3),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );

              deleteFlag ??= false;

              if (deleteFlag) {
                await taskController.deleteWithKids(taskHolder);
                Navigator.pop(context);
              }
            },
          ),
        ],
        title: Text('Expanded task screen'),
      ),
      body: FutureBuilder<Task>(
        future: taskFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final loadedTask = snapshot.data;
          return Column(
            children: <Widget>[
              _mainTaskView(context, loadedTask),
              Expanded(
                flex: 1,
                child: _buildSubtaskList(context, loadedTask),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Task newTask = await _showCreateTaskScreen(context);
          if (newTask != null) {
            final parent = await taskController.loadById(widget.task.id, depth: 0);
            await taskController.create(task: newTask, parent: parent);
            setState(() {});
          }
        },
        tooltip: 'Add new task',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<Task> _showCreateTaskScreen(BuildContext context) async {
    return Navigator.push<Task>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => CreateTaskScreen(),
        ));
  }

  Widget _mainTaskView(BuildContext context, Task task) {
    return Container(
      child: TaskViewExpanded(task),
    );
  }

  Widget _buildSubtaskList(BuildContext context, Task task) {
    return ListView(children: task.subtasks.map((task) => _buildListTile(task, context)).toList());
  }

  Widget _buildListTile(Task task, BuildContext context) {
    return ExpansionTile(
      title: _buildTaskView(task, context),
      children: task.subtasks
          .map((task) => Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 55),
                child: _buildTaskView(task, context),
              ))
          .toList(),
    );
  }

  Widget _buildTaskView(Task task, BuildContext context) => GestureDetector(
      child: TaskView(task),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ExpandedTaskScreen(task: task)),
        );
      });
}
