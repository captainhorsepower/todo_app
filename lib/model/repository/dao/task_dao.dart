import '../../task.dart';
import 'dao.dart';

class TaskDao implements Dao<Task> {
  static final tableName = 'tasks';
  static final idCol = 'id';
  static final parentIdCol = 'parent_id';
  static final titleCol = 'title';
  static final durationCol = 'expected_duration_mins';

  // TODO: add deadline col
  static final createTableQuery = 'CREATE TABLE $tableName ('
      '    $idCol BIGINT not null unique,'
      '    $parentIdCol BIGINT,'
      '    $titleCol VARCHAR(255) not null unique,'
      '    $durationCol INT,'
      '    PRIMARY KEY ($idCol),'
      '    FOREIGN KEY ($parentIdCol) REFERENCES tasks($idCol)'
      ');';

  @override
  Task fromJson(Map<String, dynamic> data) {
    return Task()
      ..id = data['$idCol'] // мне просто больше нравится, когда строка. И подсвечивает лучше
      ..parentId = data['$parentIdCol']
      ..title = data['$titleCol']
      ..expectedDuration = Duration(minutes: data['$durationCol']);
  }

  @override
  Map<String, dynamic> toJson(Task task) {
    return <String, dynamic>{
      idCol: task.id,
      parentIdCol: task.parentId,
      titleCol: task.title,
      durationCol: task.expectedDuration.inMinutes,
    };
  }
}
