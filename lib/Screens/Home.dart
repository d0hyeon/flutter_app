import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_app/constants/map.dart';
import 'package:my_app/utils/location.dart';

class Home extends StatefulWidget {
  static String routeName = '/';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _completer = Completer();
  GoogleMapController _controller;
  Marker marker = Marker(
      markerId: MarkerId('USER_MARKER${DateTime.now().toString()}'),
      alpha: 1,
      rotation: 0);

  void setCameraPosition(Position position,
      {double zoom = DEFAULT_ZOOM, tilt = DEFAULT_TILT}) {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      tilt: tilt,
      zoom: zoom,
    );
    _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void setMarkerPosition(Position position) {
    setState(() {
      marker = marker.copyWith(
          positionParam: LatLng(position.latitude, position.longitude),
          alphaParam: 1);
    });
  }

  void moveCurrnetLocation() async {
    bool serviceEnabled = await requestLocationService();
    if (!serviceEnabled) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    setCameraPosition(position);
    setMarkerPosition(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Map'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 10,
            child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: INITIAL_CAMERA_POSITION,
                    markers: {marker},
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                      _completer.complete(controller);
                    },
                    compassEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Column(
                      children: [
                        MaterialButton(
                          child: Icon(Icons.gps_fixed, color: Colors.black, size: 20),
                          shape: CircleBorder(),
                          color: Colors.white,
                          height: 35,
                          minWidth: 35,
                          onPressed: moveCurrnetLocation,
                        ),
                      ],
                    )),
                ]
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: RawMaterialButton(
                      constraints: BoxConstraints(
                        minHeight: 40,
                      ),
                      fillColor: Colors.white,
                      // shape: Border.all(
                      //   color: Colors.grey[400],
                      //   width: 1,
                      //   style: BorderStyle.solid
                      // ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: Text(
                        '산책하기',
                        style: TextStyle(
                          color: Colors.black,
                        )
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/work_out');
                      },
                    )
                  )
                  
                  // ElevatedButton(
                  //   style: ButtonTheme.fromButtonThemeData(data: data, child: child),
                  //   child: Text('산책하기'),
                  //   onPressed: () {
                  //     Navigator.pushNamed(context, '/work_out');
                  //   },
                  // )
                ],
                  )),
          )
        ],
      ),
    );
  }
}
