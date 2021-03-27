import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:my_app/app.dart';
import 'package:my_app/models/app_state.dart';
import 'package:my_app/reducers/app_reducer.dart';

void main() {
  runApp(ReduxApp(
    store: new Store<AppState>(
      appReducer,
      initialState: AppState()
    ),
  ));
}