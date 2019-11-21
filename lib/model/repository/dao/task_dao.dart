import '../../task.dart';
import 'dao.dart';

/// v 0.0.1
/// Таски строят из себя лес деревьев.
/// Таблице тасок пофиг на структуру. Дерево создаётся 
/// с помощью task_closure_table, где 
/// -- id - таска
/// -- parent_id - таска на пути от id до корня (включая)
/// -- direct_parent_id - непосредственный родитель (null для корня)
/// -- relative_depth - расстояние между id и parent_id
/// 
/// Соблюдаются следующие инварианты:
///
/// -- для любая уже загруженной таски уже 
///    либо загружен её родитель,
///    либо таска является корнем в лесу тасок.
///
/// -- таска подгружает с собой своих детей, сколько уровней? -- пока не решено
// FIXME: hardcoded values
class TaskDao implements Dao<Task> {
  // all this fields must be static, to be accessed in initalizers.
  static const tableName = 'tasks';
  static const id = 'id';
  static const parentId = 'parent_id';
  static const title = 'title';
  static const durationMins = 'duration_mins';
  static const totalDurationMins = 'total_duration_mins';
  static const createdAtUtc = 'created_at';
  static const dueToUtc = 'due_to';
  static const isDone = 'is_done';
  static const kids = 'kids';

  static const createTableQuery = 'CREATE TABLE $tableName ('
      '  $id INTEGER,'
      '  $parentId INTEGER,'
      '  $title TEXT not null,'
      '  $durationMins INT default 0,'
      '  $totalDurationMins INT not null,'
      '  $createdAtUtc TEXT not null,'
      '  $dueToUtc TEXT, '
      '  $isDone BOOLEAN not null default false,'
      '  PRIMARY KEY ($id),'
      '  FOREIGN KEY ($parentId) REFERENCES tasks($id)'
      ');';

  static const findTaskByIdQuery = """
SELECT
  task.*,
  (
    SELECT
      COALESCE(sum(kid.duration_mins), 0)
    FROM
      tasks kid
      LEFT JOIN task_tree_closure c ON kid.id = c.id
    WHERE
      c.parent_id = task.id
  ) AS total_duration_mins
FROM
  tasks task
WHERE
  task.id = ?1;
""";

  static const findTaskAndKidsByIdAndDepth = """
SELECT
  c.direct_parent_id,
  task.*,
  (
    SELECT
      COALESCE(sum(kid.duration_mins), 0)
    FROM
      tasks kid
      LEFT JOIN task_tree_closure c ON kid.id = c.id
    WHERE
      c.parent_id = task.id
  ) AS total_duration_mins
FROM
  tasks task
  LEFT JOIN task_tree_closure c ON task.id = c.id
WHERE
  c.parent_id = ?1
  AND c.relative_depth < ?2;
  """;

  /// create task from database map. Parent and subtasks are null.
  @override
  Task fromJson(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      title: data['title'],
      expectedDuration: Duration(minutes: data['duration_mins']),
      totalExpectedDuration: Duration(minutes: data['total_duration_mins']),
      createdAt: DateTime.parse(data['created_at']).toLocal(),
      dueTo: data['due_to'] != null ? DateTime.parse(data['due_to']).toLocal() : null,
      isDone: data['is_done'] != 0,
    );
  }

  @override
  Map<String, dynamic> toJson(Task task) {
    return <String, dynamic>{
      'id': task.id,
      'title': task.title,
      'duration_mins': task.expectedDuration.inMinutes,
      'created_at': task.createdAt.toUtc().toIso8601String(),
      'due_to': task.dueTo?.toUtc()?.toIso8601String(),
      'is_done': task.isDone,
    };
  }
}
