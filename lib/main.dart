import 'package:flutter/material.dart';
import 'package:todo_chunks/model/repository/database_provider.dart';
import 'package:todo_chunks/model/repository/task_repository.dart';
import 'package:todo_chunks/view/unlisted_tasks_screen.dart';

import 'model/task.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TasksRepository repo = TasksRepository();

  @override
  void initState() {
    print('initialized state');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var list = <String>[];

    list.add('str1');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          child: UnlistedTaskScreen(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('pressed button');

          print('button released UI lock');
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
