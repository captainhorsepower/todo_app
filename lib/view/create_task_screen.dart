import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/task.dart';

class CreateTaskScreen extends StatefulWidget {
  final Task task;

  const CreateTaskScreen({Key key, this.task}) : super(key: key);

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final format = DateFormat('MMMM dd, yyyy');

  final titleController = new TextEditingController();
  final durationController = new TextEditingController();
  final dueToController = new TextEditingController();
  DateTime dueTo;

  @override
  void initState() {
    if (widget.task != null) {
      titleController.text = widget.task.title;
      durationController.text = widget.task.duration.inMinutes.toString();
      dueTo = widget.task.dueTo;
      dueToController.text = dueTo == null ? '' : format.format(dueTo);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create Task' : 'Update Task'),
      ),
      body: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter a title',
                  ),
                  style: TextStyle(fontSize: 24),
                  autofocus: true,
                  controller: titleController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0, left: 40, right: 40),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Duration minutes',
                  ),
                  style: TextStyle(fontSize: 24),
                  autocorrect: false,
                  keyboardType: TextInputType.numberWithOptions(),
                  controller: durationController,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Deadline date',
                  ),
                  style: TextStyle(fontSize: 24),
                  textInputAction: TextInputAction.none,
                  controller: dueToController,
                  onTap: () async {
                    dueTo = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(Duration(days: 30)),
                      lastDate: DateTime.now().add(Duration(days: 500)),
                      initialDate: DateTime.now(),
                    );
                    if (dueTo == null) {
                      dueToController.text = '';
                      return;
                    }
                    dueTo = DateTime(dueTo.year, dueTo.month, dueTo.day, 23, 59, 59);
                    dueToController.text = format.format(dueTo);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          final title = titleController.text;
          final durationText = durationController.text;

          if (title.isNotEmpty && durationText.isNotEmpty) {
            final duration = Duration(minutes: int.parse(durationText));
            Navigator.pop(
                context,
                Task(
                  id: widget.task?.id,
                  parent: widget.task?.parent,
                  title: title,
                  duration: duration,
                  createdAt: widget.task?.createdAt ?? DateTime.now(),
                  dueTo: dueTo,
                ));
            return;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    durationController.dispose();
    titleController.dispose();
    dueToController.dispose();
    super.dispose();
  }
}
