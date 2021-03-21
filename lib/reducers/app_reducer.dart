import 'package:my_app/models/app_state.dart';
import 'package:my_app/reducers/todo.dart';

AppState appReducer(AppState state, action) {
  return AppState(todos: todoReducer(state.todos, action));
}
