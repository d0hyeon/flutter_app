import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

enum Actions { Increment }

int counterReducer(int state, dynamic action) {
  if (action == Actions.Increment) {
    return state + 1;
  }

  return state;
}

void main() {
  final store = new Store<int>(counterReducer, initialState: 0);

  runApp(new MyApp(
    title: 'Flutter Redux Demo',
    store: store,
  ));
}

class MyApp extends StatelessWidget {
  final Store<int> store;
  final String title;

  MyApp({Key key, this.store, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<dynamic>(
        store: store,
        child: new MaterialApp(
            theme: ThemeData.dark(),
            title: title,
            home: ReduxHome(this.title)));
  }
}

class ReduxHome extends StatelessWidget {
  final String title;
  ReduxHome(this.title) : super();

  final count = StoreConnector(
    converter: (store) => store.state, builder: (context, count) => count);
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: Text(title),
        ),
        body: Center(
            child: Column(
          children: [
            new StoreConnector(
              converter: (store) => store.state.toString(),
              builder: (context, count) => Text(count),
            ),
          ],
        )),
        floatingActionButton: new StoreConnector(converter: (store) {
          return () => store.dispatch(Actions.Increment);
        }, builder: (context, callback) {
          return new FloatingActionButton(
              onPressed: callback, tooltip: '눌러봐', child: Text('눌러봐~~'));
        }));
  }
}
