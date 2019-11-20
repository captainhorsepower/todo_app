import 'package:flutter/material.dart';
import 'package:todo_chunks/model/repository/task_repository.dart';

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

    print ('initialized state');

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('pressed button');
          final query = """
            insert into tasks (id, title, parent_id) 
            values 
            (1, 'root 1', null),
              (2, 'node 1.2', 1),
              (3, 'node 1.3', 1),
              (4, 'node 1.4', 1),

            -- root 2
            (100, 'root 2', null),
              --level 1
              (101, 'node 2.1', 100),
              (102, 'node 2.2', 100),
                -- level 2
                (111, 'node 2.1.1', 101),
                (112, 'node 2.1.2', 101),
                (113, 'node 2.1.3', 101),

                (121, 'node 2.2.1', 102),
                (122, 'node 2.2.2', 102),

            -- root 3
            (200, 'root 3', null);
            """;
          final query2 = 'SELECT * FROM tasks where parent_id is null;';

          Task task = Task()
          ..title = 'повторить графы'
          ..expectedDuration = Duration(hours: 2);
          repo.save(task);
          // repo.doQuery(query2);
          print('button released UI lock');
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
