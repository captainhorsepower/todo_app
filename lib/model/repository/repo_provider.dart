import 'package:todo_chunks/model/repository/task_repository.dart';

class RepositoryProvider {
  static final _instance = RepositoryProvider._createInstance();

  final _tasksRepository = TaskRepository();

  RepositoryProvider._createInstance();
  static RepositoryProvider get instance => _instance;

  TaskRepository get taskRepo => _tasksRepository;
}
