import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/task.dart';

class TaskView extends StatelessWidget {
  final Task task;

  TaskView(this.task);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        decoration: BoxDecoration(border: Border.all()),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text(task.title),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('created: ${formatDate(task.createdAt)}'),
                    ),
                    Expanded(
                      flex: 1,
                      child:
                          task.dueTo == null ? Text('') : Text('due to: ${formatDate(task.dueTo)}'),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Text('${task.expectedDuration.inMinutes}'),
                    ),
                    Expanded(
                      child: Text('${task.totalExpectedDuration.inMinutes}'),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    final format = DateFormat('dd MMMM hh:mm a');
    return format.format(dateTime);
  }
}
