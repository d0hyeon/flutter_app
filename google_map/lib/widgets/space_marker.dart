import 'package:flutter/material.dart';
import 'package:my_app/utils/clipper.dart';

class SpaceMarker extends StatelessWidget {
  Text text;
  Color backgroundColor;

  SpaceMarker(this.text, {backgroundColor}) : backgroundColor = backgroundColor ?? Colors.green.shade300;
  @override

  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topStart,
      textDirection: TextDirection.ltr,
      fit: StackFit.loose,
      children: [
        Container(
          width: 80,
          height: 80,
          margin: EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(200))
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [text]
          ),
        ),
        Positioned(
          left: 10,
          top: 70,
          child: ClipPath(
            clipper: TriangleClipper(),
            child: Container(
              color: backgroundColor,
              height: 40,
              width: 60,
            ),
          ),
        )
      ],
    );
  }
}
