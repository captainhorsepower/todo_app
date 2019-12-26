import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_chunks/view/rebuild_trigger.dart';
import 'package:todo_chunks/view/unlisted_tasks_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // TODO: remove it
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(brightness: Brightness.dark),
      home: ChangeNotifierProvider(
        builder: (_) => RebuildTrigger(),
        child: MyHomePage(title: 'Unlisted Tasks'),
      ),
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
  @override
  Widget build(BuildContext context) {
    return UnlistedTaskScreen();
  }
}
