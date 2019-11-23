import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  Duration duration;

  /// this.expectedDuration + (all subtasks (recursive)).expectedDuration
  Duration totalDuration;

  /// creation time, uts
  DateTime createdAt;

  /// deadline time, utc
  DateTime dueTo;

  bool isDone;

  Task({
    this.id,
    this.parent,
    this.subtasks,
    @required this.title,
    this.duration,
    this.totalDuration,
    this.createdAt,
    this.dueTo,
    this.isDone = false,
  }) {
    createdAt ??= DateTime.now();
    subtasks ??= [];
    duration ??= Duration(minutes: 30);
  }

  Task copyWith({
    int id,
    Task parent,
    String title,
    List<Task> subtasks,
    Duration duration,
    DateTime createdAt,
    DateTime dueTo,
    bool isDone,
  }) {
    return Task(
      id: id ?? this.id,
      parent: parent ?? this.parent,
      title: title ?? this.title,
      subtasks: subtasks ?? this.subtasks,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      dueTo: dueTo ?? this.dueTo,
      isDone: isDone ?? this.isDone,
    );
  }
}
