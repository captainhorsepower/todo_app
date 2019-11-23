import 'package:flutter/material.dart';
import 'package:todo_chunks/model/service/service_provider.dart';

import '../service/task_service.dart';
import '../task.dart';

class TaskController {
  TaskService taskService = ServiceProvider.instance.taskService;

  Future<Task> create({@required Task task, Task parent}) async {
    assert(task != null);
    assert(task.id == null);

    if (parent == null) {
      task = await taskService.saveRoot(task);
    } else {
      task = await taskService.saveChild(task, parent);
    }

    return task;
  }

  Future<Task> update(Task task, {String title, Duration duration, DateTime dueTo}) async {
    assert(task != null);

    task = task.copyWith(title: title, duration: duration, dueTo: dueTo);
    await taskService.update(task);

    return task;
  }

  Future<Task> setDone(Task task, bool isDone) async {
    assert(task != null);
    assert(isDone != null);
    assert(task.id != null);

    task = task.copyWith(isDone: isDone);
    await taskService.update(task);
    
    return task;
  }

  Future<void> deleteWithKids(Task task) async {
    assert(task != null);
    assert(task.id != null);
    
    await taskService.deleteWithKids(task);
  }
}
