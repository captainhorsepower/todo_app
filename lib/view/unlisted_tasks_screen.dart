import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todo_chunks/model/repository/task_repository.dart';
import 'package:todo_chunks/model/task.dart';
import 'package:todo_chunks/view/expanded_task_screen.dart';
import 'package:todo_chunks/view/task_view.dart';

class UnlistedTaskScreen extends StatefulWidget {
  @override
  _UnlistedTaskScreenState createState() => _UnlistedTaskScreenState();
}

class _UnlistedTaskScreenState extends State<UnlistedTaskScreen> {
  List<Task> tasks;

  TasksRepository repo = TasksRepository();

  @override
  void initState() {
    repo.findWithChildrenById(1, 100).then((task) => {
          this.setState(() => {
                tasks = [task]
              })
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: tasks == null
          ? CircularProgressIndicator()
          : ListView(
              children: tasks.map((task) => _buildListTile(task, context)).toList(),
            ),
    );
  }

  Widget _buildListTile(Task task, BuildContext context) {
    return ExpansionTile(
      leading: Text('leading'),
      title: TaskView(task),
      trailing: Text('trailing'),
      // children: task.subtasks.map((task) => TaskView(task)).toList(),
      children: task.subtasks
          .map(
            (task) => GestureDetector(
              child: Hero(
                tag: task.title,
                child: TaskView(task),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpandedTaskScreen(
                            task: task,
                          )),
                );
              },
            ),
          )
          .toList(),
    );
  }
}
