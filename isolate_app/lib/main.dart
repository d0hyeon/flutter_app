import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:isolate';

void main() {
  runApp(App());
}

void parrotTask (SendPort mainPort) {
  final ReceivePort backgroundPort = ReceivePort();
  mainPort.send(backgroundPort.sendPort);
  backgroundPort.listen((message) {
    mainPort.send('$message (origin - parrot)');
  }); 
}

class App extends StatelessWidget {
  final ReceivePort mainPort = ReceivePort();
  SendPort backgroundPort;
  Isolate backgroundIsolate;
  StreamSubscription mainPortStream;

  Future<void> createIsolate () async {
    Completer completer = Completer();

    mainPortStream = mainPort.listen((dynamic message) {
      if(message is SendPort) {
        backgroundPort = message;
        completer.complete('');
      } else {
        print(message);
      }
    });
  
    backgroundIsolate = await Isolate.spawn(parrotTask, mainPort.sendPort);
    return completer.future;
  }

  App() {
    print('start background isolate!');
    createIsolate()
      .then((_) {
        backgroundPort.send('hi');
        backgroundPort.send('nice');
      });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate App',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Isolate App')
        ),
        body: Center(
          child: Text('hi!')
        )
      )
    );
  }
}