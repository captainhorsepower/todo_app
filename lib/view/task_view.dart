import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taptic_feedback/taptic_feedback.dart';

import '../model/controller/controller_provider.dart';
import '../model/task.dart';
import 'expanded_task_screen.dart';
import 'rebuild_trigger.dart';

class TaskView extends StatelessWidget {
  final Task task;
  final taskController = ControllerProvider.instance.taskController;

  TaskView(this.task);

  @override
  Widget build(BuildContext context) {
    final clr = Theme.of(context).accentColor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        width: 240,
        decoration: BoxDecoration(
          border: Border.all(color: clr),
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(flex: 1, child: _buildDoneButton(context)),
              Expanded(flex: 4, child: _buildTaskLayout(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    final clr = Theme.of(context).accentColor;
    final size = 30.0;

    final canComplete = this.task.subtasks.isEmpty;

    final trigger = Provider.of<RebuildTrigger>(context);

    final func = () async {
      if (canComplete) {
        TapticFeedback.fromCode(1394);
        await taskController.setDone(task, true);
        trigger.trigger();
      }
    };

    return GestureDetector(
      child: Center(
        child: Icon(
          Icons.done_outline,
          size: size,
          color: canComplete ? clr : clr.withOpacity(0.5),
        ),
      ),
      onTap: func,
      onLongPress: func,
    );
  }

  Widget _buildTaskLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        child: Column(
          children: <Widget>[
            Expanded(flex: 3, child: _buildTitleRow(context)),
            Expanded(flex: 1, child: _buildLeftTimeRow(context)),
          ],
        ),
        onTap: () {
          TapticFeedback.light();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                        builder: (_) => RebuildTrigger(),
                        child: ExpandedTaskScreen(task),
                      )));
        },
        onForcePressPeak: (_) => TapticFeedback.tripleStrong(),
        onLongPress: () => TapticFeedback.doubleStrong(),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Center(
      child: Text(
        task.title,
        textScaleFactor: 1.5,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLeftTimeRow(BuildContext context) {
    final clr = Theme.of(context).accentColor;
    Duration timeLeft = task.dueTo?.difference(DateTime.now());
    return Text(
      'hours left: ${timeLeft?.inHours ?? 'unlimited!'}',
      textAlign: TextAlign.left,
      style: TextStyle(color: clr),
    );
  }
}

class TaskViewExpanded extends StatelessWidget {
  final Task task;
  final taskController = ControllerProvider.instance.taskController;

  TaskViewExpanded(this.task);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 130,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(flex: 1, child: _buildDoneButton(context)),
              Expanded(flex: 4, child: _buildTaskLayout(context)),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    if (dateTime == null) return null;
    final format = DateFormat('MMMM dd,  hh:mm ');
    return format.format(dateTime);
  }

  Widget _buildDoneButton(BuildContext context) {
    final clr = Theme.of(context).accentColor;
    final size = 50.0;

    final canComplete = this.task.subtasks.isEmpty;

    final func = () async {
      if (canComplete) {
        TapticFeedback.fromCode(1394);
        await taskController.setDone(task, true);
        Navigator.pop(context);
      }

      TapticFeedback.fromCode(1519);
    };

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: clr),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: GestureDetector(
        child: Center(
          child: Icon(
            Icons.done_all,
            size: size,
            color: canComplete ? clr : clr.withOpacity(0.5),
          ),
        ),
        onTap: func,
        onLongPress: func,
      ),
    );
  }

  Widget _buildTaskLayout(BuildContext context) {
    final clr = Theme.of(context).accentColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: clr),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: Column(
            children: <Widget>[
              Expanded(flex: 3, child: _buildTitleRow(context)),
              Expanded(flex: 1, child: _buildDurationRow(context)),
              Expanded(flex: 2, child: _buildDateRow(context)),
            ],
          ),
        ),
        onForcePressPeak: (_) => TapticFeedback.tripleStrong(),
        onLongPress: () => TapticFeedback.doubleStrong(),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          task.title,
          textScaleFactor: 1.8,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDurationRow(BuildContext context) {
    final clr = Theme.of(context).accentColor;
    return Row(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Text(
              '${task.duration.inMinutes} min',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        Expanded(
            flex: 2,
            child: Text(
              '${task.totalDuration.inMinutes} in total',
              textAlign: TextAlign.center,
              style: TextStyle(color: clr),
            )),
      ],
    );
  }

  Widget _buildDateRow(BuildContext context) {
    final clr = Theme.of(context).accentColor;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'created at:',
                textAlign: TextAlign.right,
                style: TextStyle(color: clr),
              ),
              Text(
                'due to:',
                textAlign: TextAlign.right,
                style: TextStyle(color: clr),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            children: <Widget>[
              Text(
                '${formatDate(task.createdAt)}',
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${formatDate(task.dueTo) ?? ''}',
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
