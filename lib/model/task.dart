/// self-contained task, knows about 
/// itself, other connected tasks and nothing esle.
class Task {

  int id;

  /// direct parent, userful for updates
  Task parent;

  /// direct kids, each one have this task as parent
  List<Task> subtasks;

  String title;

  /// time, that this task is supposed to take
  Duration expectedDuration;

  /// this.expectedDuration + (all subtasks (recursive)).expectedDuration
  Duration totalExpectedDuration;

  /// creation time, uts
  DateTime createdAt;

  /// deadline time, utc
  DateTime dueTo;

  bool isDone;

}
