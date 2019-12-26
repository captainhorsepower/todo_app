import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_chunks/view/rebuild_trigger.dart';

import '../model/controller/controller_provider.dart';
import '../model/task.dart';
import 'create_task_screen.dart';
import 'task_view.dart';

class ExpandedTaskScreen extends StatelessWidget {
  final Task task;
  final taskController = ControllerProvider.instance.taskController;

  ExpandedTaskScreen(this.task);

  @override
  Widget build(BuildContext context) {
    final taskFuture = taskController.loadById(task.id, depth: 2);

    var taskHolder = task;
    taskFuture.then((task) => taskHolder = task);

    final trigger = Provider.of<RebuildTrigger>(context);

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.compare_arrows),
            onPressed: () async {
              final parentId = await showDialog(
                  context: context,
                  builder: (_) {
                    final controller = TextEditingController();
                    return Dialog(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter parent id',
                              ),
                              style: TextStyle(fontSize: 24),
                              autofocus: true,
                              controller: controller,
                            ),
                          ),
                          ...<Widget>[
                            FlatButton(
                                child: Text('Move to root'),
                                onPressed: () => Navigator.pop(context, 0)),
                            FlatButton(
                              child: Text('Move to parent'),
                              onPressed: () {
                                if (controller.text.isEmpty) return;

                                var parentId = int.parse(controller.text);
                                if (parentId > 0) {
                                  Navigator.pop(context, parentId);
                                }
                              },
                            ),
                            FlatButton(
                                child: Text('Cancel'), onPressed: () => Navigator.pop(context, -1)),
                          ],
                        ],
                      ),
                    );
                  });

              if (parentId == 0) {
                taskController.moveSubtree(task).then((_) =>
                    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName)));
                return;
              }
              if (parentId > 0) {
                taskController
                    .moveSubtree(task, newParent: Task(id: parentId))
                    .then((_) => Navigator.pop(context));
                return;
              }
            },
          ),
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
                trigger.trigger();
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
        title: Text(
          '#${task.id}',
        ),
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
            await taskController.create(task: newTask, parent: task);
            trigger.trigger();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TaskView(task),
    );
  }
}
