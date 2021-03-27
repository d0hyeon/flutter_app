import 'package:uuid/uuid.dart';

class Todo {
  final bool complete;
  final String id;
  final String note;
  final String task;

  Todo(this.task, {this.complete = false, note = '', id})
      : note = note ?? '',
        id = id ?? Uuid().v4();
  Todo copyWith({bool complete, String note, String task}) {
    return Todo(task ?? this.task,
        id: this.id,
        complete: complete ?? this.complete,
        note: note ?? this.note);
  }
}
