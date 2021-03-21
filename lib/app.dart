import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_app/models/app_state.dart';
import 'package:my_app/screens/home.dart';

class ReduxApp extends StatelessWidget {
  final Store<AppState> store;
  ReduxApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: store,
        child: MaterialApp(
            theme: ThemeData.dark(), title: 'Flutter Redux App', home: Home()));
  }
}
