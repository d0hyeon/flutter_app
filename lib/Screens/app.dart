import 'package:flutter/material.dart';
import 'package:my_app/screens/home.dart';
import 'package:my_app/screens/work_out.dart';
import 'package:my_app/screens/work_out_result.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Map', 
      theme: ThemeData.dark(), 
      initialRoute: '/',
      routes: {
        Home.routeName: (context) => Home(),
        Workout.routeName: (context) => Workout(),
        WorkoutResult.routeName: (context) => WorkoutResult()
      }
    );
  }
}
