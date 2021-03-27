import 'package:flutter/material.dart';
import 'package:my_app/actions/actions.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_app/models/app_state.dart';
import 'package:my_app/models/models.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  TodoItem(this.todo, {Key key}) : super(key: key);

  void _handleDeleteTodo(BuildContext context) {
    ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
        content: Text('삭제 되었습니다.'),
        duration: Duration(seconds: 1),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: Colors.black54, style: BorderStyle.solid)),
        child: StoreConnector<AppState, Store<AppState>>(
          converter: (store) => store,
          builder: (context, store) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                        value: todo.complete,
                        onChanged: (value) {
                          store.dispatch(UpdateTodoAction(
                              todo.id, todo.copyWith(complete: value)));
                        }),
                    Text(todo.task),
                  ],
                ),
                Center(
                    child: IconButton(
                  iconSize: 25,
                  icon: Icon(Icons.delete_outline,
                      size: 25, color: Colors.white60),
                  onPressed: () {
                    store.dispatch(DeleteTodoAction(todo.id));
                    _handleDeleteTodo(context);
                  },
                ))
              ],
            );
          },
        ));
  }
}
