import 'package:redux/redux.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/actions/actions.dart';

final todoReducer = combineReducers<List<Todo>>([
  TypedReducer<List<Todo>, AddTodoAction>(_addTodo),
  TypedReducer<List<Todo>, DeleteTodoAction>(_deleteTodo),
  TypedReducer<List<Todo>, UpdateTodoAction>(_updateTodo),
]);

List<Todo> _addTodo(List<Todo> todos, AddTodoAction action) {
  return List.from(todos)..add(action.todo);
}

List<Todo> _deleteTodo(List<Todo> todos, DeleteTodoAction action) {
  return todos.where((todo) => todo.id != action.id).toList();
}

List<Todo> _updateTodo(List<Todo> todos, UpdateTodoAction action) {
  final Todo updateTodo = action.updateTodo;

  return todos.map((todo) {
    if (todo.id == action.id) {
      return todo.copyWith(
          task: updateTodo.task,
          note: updateTodo.note,
          complete: updateTodo.complete);
    }
  }).toList();
}
