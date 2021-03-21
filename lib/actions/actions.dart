import '../models/todo.dart';

class AddTodoAction {
  final Todo todo;

  AddTodoAction(this.todo);

  @override
  String toString() {
    return 'add todo ${this.todo}';
  }
}

class DeleteTodoAction {
  final String id;

  DeleteTodoAction(this.id);
}

class UpdateTodoAction {
  final String id;
  final Todo updateTodo;

  UpdateTodoAction(this.id, this.updateTodo);

  @override
  String toString() {
    return 'update todo ${this.updateTodo}';
  }
}
