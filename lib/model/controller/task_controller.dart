import '../service/task_service.dart';
import '../task.dart';

class TaskController {
  TaskService taskService;

  Future<Task> createNewTask(Task task) async {
    task = await taskService.save(task);
    return task;
  }
}
