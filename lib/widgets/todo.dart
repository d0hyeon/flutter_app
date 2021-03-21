import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_app/models/app_state.dart';
import 'package:my_app/models/todo.dart';
import 'package:my_app/widgets/todo_item.dart';

class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Todo>>(
        converter: (store) => store.state.todos,
        builder: (context, todos) {
          if (todos.isEmpty) {
            return Text('Todo가 없습니다.');
          } else {
            return ListView(
              children: todos.map((Todo todo) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child:  TodoItem(todo)
                );
              }).toList(),
            );
          }
        });
  }
}
