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

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.compare_arrows),
            onPressed: _doReorder(context),
          ),
          IconButton(
            icon: Icon(Icons.create),
            onPressed: _doEdit(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _doDelete(context),
          ),
        ],
        title: Text('#${task.id}'),
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
              _buildTaskView(context, loadedTask),
              Expanded(
                child: _buildSubtaskList(context, loadedTask),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _doCreate(context),
        tooltip: 'Add new task',
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

  Widget _buildTaskView(BuildContext context, Task task) {
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

  _doReorder(context) => () async {
        final parentId = await showDialog(
          context: context,
          builder: (_) => ReorderDialog(task.id),
        );

        if (parentId == null) return;

        if (parentId == 0) {
          taskController.moveSubtree(task).then((_) => Navigator.popUntil(
              context,
              ModalRoute.withName(
                Navigator.defaultRouteName,
              )));
        } else if (parentId > 0) {
          taskController
              .moveSubtree(task, newParent: Task(id: parentId))
              .then((_) => Navigator.pop(context));
        }
      };

  _doEdit(context) => () async {
        final updatedTask = await Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => CreateTaskScreen(task: task),
          ),
        );

        if (updatedTask != null) {
          await taskController.update(updatedTask);
          final trigger = Provider.of<RebuildTrigger>(context);
          trigger.trigger();
        }
      };

  _doDelete(context) => () async {
        bool deleteFlag = await showDialog(
          context: context,
          builder: (context) => DeleteDialog(),
        );

        deleteFlag ??= false;

        if (deleteFlag) {
          await taskController.deleteWithKids(task);
          Navigator.pop(context);
        }
      };

  _doCreate(context) => () async {
        Task newTask = await _showCreateTaskScreen(context);
        if (newTask != null) {
          await taskController.create(task: newTask, parent: task);

          final trigger = Provider.of<RebuildTrigger>(context);

          trigger.trigger();
        }
      };
}

class ReorderDialog extends StatelessWidget {
  final controller = TextEditingController();
  final myId;

  ReorderDialog(this.myId);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: TextField(
              decoration: InputDecoration(hintText: 'Enter parent id'),
              style: TextStyle(fontSize: 24),
              keyboardType: TextInputType.number,
              autofocus: true,
              controller: controller,
            ),
          ),
          ...<Widget>[
            FlatButton(
              child: Text('Move to root'),
              onPressed: () => Navigator.pop(context, 0),
            ),
            FlatButton(
              child: Text('Move to parent'),
              onPressed: () {
                if (controller.text.isEmpty) return;

                var parentId = int.parse(controller.text);
                if (parentId > 0 && parentId != myId) {
                  Navigator.pop(context, parentId);
                }
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}

class DeleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
