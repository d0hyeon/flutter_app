import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_app/actions/actions.dart';
import 'package:my_app/models/app_state.dart';
import 'package:my_app/models/models.dart';
import 'package:redux/redux.dart';

@immutable
class TodoForm extends StatelessWidget {
  TextEditingController controller = TextEditingController();

  Future<void> _handleAddTask(BuildContext context) {
    final Duration duration = Duration(seconds: 1);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('생성 되었습니다.'),
      duration: duration,
    ));
    Future.delayed(duration, () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create Task'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Form(
              child: Column(
            children: [
              TextField(
                controller: controller,
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6.00))),
                  labelText: '할일',
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0)),
              StoreConnector<AppState, Store<AppState>>(
                  converter: (store) => store,
                  builder: (ctx, store) {
                    return ElevatedButton(
                        onPressed: () {
                          store.dispatch(AddTodoAction(Todo(controller.text)));
                          _handleAddTask(context);
                        },
                        child: Text('추가'));
                  })
            ],
          )),
        )));
  }
}
