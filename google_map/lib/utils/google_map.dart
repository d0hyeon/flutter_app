import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createUserMarkerIcon() {
  return BitmapDescriptor.fromAssetImage(
    ImageConfiguration(size: Size.square(30)), 
      'assets/images/dot.png'
    );
}