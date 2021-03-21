import 'package:flutter/material.dart';
import 'package:my_app/screens/todo_form.dart';
import 'package:my_app/widgets/todo.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Todo App'), centerTitle: true, elevation: 0.0),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30), child: TodoList()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black38,
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => TodoForm()));
        },
      ),
    );
  }
}
