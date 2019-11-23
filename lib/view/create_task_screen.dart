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
  final format = DateFormat('dd MMM hh:mm a');

  final titleController = new TextEditingController();
  final durationController = new TextEditingController();
  DateTime dueTo;

  @override
  void initState() {
    if (widget.task != null) {
      titleController.text = widget.task.title;
      durationController.text = widget.task.expectedDuration.inMinutes.toString();
    }
    dueTo = widget.task?.dueTo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create / Update Task'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Title',
                  textScaleFactor: 2,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter a task title',
                  ),
                  autofocus: true,
                  controller: titleController,
                ),
                Text(
                  'Duration',
                  textScaleFactor: 2,
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Duration in minutes'),
                  autocorrect: false,
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  controller: durationController,
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: MaterialButton(
                    color: Colors.black12,
                    child: Text(
                      'Due to: ${dueTo == null ? '' : format.format(dueTo)}',
                      textScaleFactor: 1.5,
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 500)),
                        initialDate: DateTime.now(),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        dueTo = time == null
                            ? null
                            : DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
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
                Task(
                  id: widget.task?.id,
                  parent: widget.task?.parent,
                  title: title,
                  expectedDuration: duration,
                  createdAt: widget.task?.createdAt ?? DateTime.now(),
                  dueTo: dueTo,
                ));
            return;
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    durationController.dispose();
    titleController.dispose();
    super.dispose();
  }
}
