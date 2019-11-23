import 'package:todo_chunks/model/controller/task_controller.dart';

// each 'class' also defines an interface, what I've done is okay.
class ControllerProvider {
  static final _instance = ControllerProvider._createInstance();

  final _taskController = TaskController();

  ControllerProvider._createInstance();
  static ControllerProvider get instance => _instance;

  TaskController get taskController => _taskController;
}
