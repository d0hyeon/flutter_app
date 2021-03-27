import 'package:google_maps_flutter/google_maps_flutter.dart';

const double DEFAULT_ZOOM = 15.0;
const double DEFAULT_TILT = 10.0;

const CameraPosition INITIAL_CAMERA_POSITION = CameraPosition(
    target: LatLng(37.586657090293286, 126.97479363360962), tilt: DEFAULT_TILT, zoom: DEFAULT_ZOOM);

enum MapLocationState { dynamic, static }
