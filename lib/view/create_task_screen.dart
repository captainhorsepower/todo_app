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
  final dateFormat = DateFormat('MMMM dd, yyyy');
  final timeFormat = DateFormat('HH:mm');

  final titleController = TextEditingController();
  final durationController = TextEditingController();
  final dueToController = TextEditingController();
  final dueToTimeController = TextEditingController();

  DateTime dueToDateTime;
  TimeOfDay dueToTime = TimeOfDay(hour: 23, minute: 59);

  @override
  void initState() {
    if (widget.task != null) {
      titleController.text = widget.task.title;
      durationController.text = widget.task.duration.inMinutes.toString();
      dueToDateTime = widget.task.dueTo;
    }
    dueToController.text = dueToDateTime == null ? '' : dateFormat.format(dueToDateTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create Task' : 'Update Task'),
      ),
      body: ListView(
        physics: PageScrollPhysics(),
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
              readOnly: true,
              controller: dueToController,
              onTap: () async {
                dueToDateTime = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(Duration(days: 5)),
                  lastDate: DateTime.now().add(Duration(days: 500)),
                  initialDate: DateTime.now(),
                );
                if (dueToDateTime == null) {
                  dueToController.text = '';
                  return;
                }
                dueToDateTime = DateTime(dueToDateTime.year, dueToDateTime.month, dueToDateTime.day,
                    dueToTime.hour, dueToTime.minute);
                dueToController.text = dateFormat.format(dueToDateTime);
                dueToTimeController.text = timeFormat.format(dueToDateTime);
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(40),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Deadline time',
              ),
              style: TextStyle(fontSize: 24),
              readOnly: true,
              controller: dueToTimeController,
              onTap: () async {
                Duration tmp = Duration(
                    minutes: TimeOfDay.now().minute +
                            TimeOfDay.now().hour * 60 +
                            widget.task?.duration?.inMinutes ??
                        0);
                dueToTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: tmp.inHours, minute: tmp.inMinutes % 60));
                if (dueToTime == null) {
                  dueToTime = TimeOfDay(hour: 23, minute: 59);
                  if (dueToDateTime == null) {
                    dueToTimeController.text = '';
                    return;
                  }
                }
                dueToDateTime ??= DateTime.now();
                dueToDateTime = DateTime(
                  dueToDateTime.year,
                  dueToDateTime.month,
                  dueToDateTime.day,
                  dueToTime.hour,
                  dueToTime.minute,
                );
                dueToController.text = dateFormat.format(dueToDateTime);
                dueToTimeController.text = timeFormat.format(dueToDateTime);
                setState(() {});
              },
            ),
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
                //TODO: use Task.copyWith
                Task(
                  id: widget.task?.id,
                  parent: widget.task?.parent,
                  title: title,
                  duration: duration,
                  createdAt: widget.task?.createdAt ?? DateTime.now(),
                  dueTo: dueToDateTime,
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
    dueToTimeController.dispose();
    super.dispose();
  }
}
