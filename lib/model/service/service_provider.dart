import 'dart:developer';

import 'package:todo_chunks/model/service/task_service.dart';

class ServiceProvider {
  static final _instance = ServiceProvider._createInstance();

  final _taskService = TaskService();

  ServiceProvider._createInstance();
  static ServiceProvider get instance => _instance;

  TaskService get taskService => _taskService;
}
