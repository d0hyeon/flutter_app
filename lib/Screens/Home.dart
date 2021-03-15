import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      appBar: AppBar(title: Text('OdNh'), centerTitle: true, elevation: 0.0),
      body: Padding(
        padding: EdgeInsets.fromLTRB(30, 40, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Name',
                style: TextStyle(
                  color: Colors.black87,
                  letterSpacing: 2.0,
                )
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'BBANTO',
                style: TextStyle(
                  color: Colors.black87,
                  letterSpacing: 2.0,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)
                ),
              Text(
                'BBANTO PWOER LEVEL',
                style: TextStyle(
                  color: Colors.black87,
                  letterSpacing: 2.0,
                )
              ),
              SizedBox(
                height: 20,
              ),
              Text('14',
                style: TextStyle(
                  color: Colors.black87,
                  letterSpacing: 2.0,
                  fontSize: 28,
                  fontWeight: FontWeight.bold
                )
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.check_circle_outline),
                    Text(
                      'using lightsaber', 
                      style: TextStyle(
                        fontSize: 16.0,
                        letterSpacing: 1.0
                      )
                    ),
                  ]
                )
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.check_circle_outline),
                    Text(
                      'using fireball', 
                      style: TextStyle(
                        fontSize: 16.0,
                        letterSpacing: 1.0
                      )
                    ),
                  ]
                )
              )
            ]
          )
        )
      );
  }
}
