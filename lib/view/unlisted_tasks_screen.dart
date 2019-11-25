import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:todo_chunks/model/repository/database_provider.dart';
import 'package:todo_chunks/view/rebuild_trigger.dart';

import '../model/task.dart';
import '../model/controller/controller_provider.dart';
import 'task_view.dart';
import 'create_task_screen.dart';

class UnlistedTaskScreen extends StatelessWidget {
  final taskController = ControllerProvider.instance.taskController;

  @override
  Widget build(BuildContext context) {
    final tasksFuture = taskController.loadAllRoots();
    final trigger = Provider.of<RebuildTrigger>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('All Tasks'),
      ),
      body: FutureBuilder(
        future: tasksFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Task> tasks = snapshot.data;
          return ListView(
            children: tasks.map((task) => _buildListTile(task, context)).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new task',
        child: Icon(Icons.add, size: 50),
        onPressed: () async {

          /// on device database debugging (kinda)
          // final db = await DatabaseProvider.instance.database;
          // await db.rawUpdate('update tasks set is_done = 0 where id = 58');
          // final result = await db.rawQuery('select id, is_done from tasks where title = "UI tweaks"');
          // await showDialog(
          //   context: context,
          //   builder: (context) => GestureDetector(
          //     onTap: () => Navigator.pop(context),
          //     child: ListView(
          //       children: result
          //           .map(
          //             (res) => Text(
          //               '$res',
          //               textScaleFactor: 1,
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.normal,
          //                 fontSize: 12,
          //               ),
          //             ),
          //           )
          //           .toList(),
          //     ),
          //   ),
          // );
          final newTask = await _showCreateTask(context);
          if (newTask != null) {
            await taskController.create(task: newTask);
            trigger.trigger();
          }
        },
      ),
    );
  }

  Future<Task> _showCreateTask(BuildContext context) {
    return Navigator.push<Task>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => CreateTaskScreen(),
        ));
  }

  Widget _buildListTile(Task task, BuildContext context) {
    return ExpansionTile(
      title: _buildTaskView(task, context),
      children: task.subtasks.map((task) => _buildTaskView(task, context)).toList(),
    );
  }

  Widget _buildTaskView(Task task, BuildContext context) => TaskView(task);
}
