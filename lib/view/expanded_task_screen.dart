import 'package:flutter/material.dart';
import 'package:todo_chunks/model/repository/task_repository.dart';
import 'package:todo_chunks/view/task_view.dart';

import '../model/task.dart';

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 37),
              child: TaskView(widget.task),
            ),
          ),
        ),
      ),
      body: task == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: task.subtasks.map((task) => TaskView(task)).toList(),
            ),
    );
  }
}
