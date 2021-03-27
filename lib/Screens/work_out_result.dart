import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/constants/map.dart';

class WorkoutResultArguments {
  final Set<Position> routes;

  WorkoutResultArguments({this.routes});
}

class WorkoutResult extends StatefulWidget {
  static String routeName = '/work_out_result';

  @override
  _WorkoutResultState createState() => _WorkoutResultState();
}

class _WorkoutResultState extends State<WorkoutResult> {
  final Completer<GoogleMapController> _completer = Completer();
  final PolylineId polylineId = PolylineId(DateTime.now().toString());

  List<Position> routes = [];
  Set<Polyline> polylines = {};
  CameraPosition initialCameraPosition = INITIAL_CAMERA_POSITION;
  GoogleMapController _controller;
  bool isInitialize = false;

  Future<void> drawingRoute() async {
    setState(() {
      polylines.add(Polyline(
          polylineId: polylineId,
          color: Colors.red[600],
          points: routes.map((position) {
            return LatLng(position.latitude, position.longitude);
          }).toList()));
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final WorkoutResultArguments arguments =
        ModalRoute.of(context).settings.arguments;

    routes.addAll(arguments.routes.toList());
    drawingRoute().then((_) {
      setState(() {
        Position centerRoute = routes[((routes.length - 1) / 2).floor()];
        initialCameraPosition = CameraPosition(
            target: LatLng(centerRoute.latitude, centerRoute.longitude),
            tilt: DEFAULT_TILT,
            zoom: 15);
        isInitialize = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Workout'),
        ),
        body: isInitialize
            ? GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                  _completer.complete(controller);
                },
                polylines: polylines)
            : Container(child: Text('Loading...')));
  }
}
