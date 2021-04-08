import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';


class Space {
  LatLng latlng;
  String title;
  String description;
  int count;
  List<String> images;

  Space({
    @required this.latlng,
    @required this.title,
    this.description = '',
    this.count = 0,
    this.images = const []
  });

  Space copySpace({
    LatLng latlngParam, 
    String titleParam, 
    String descriptionParam, 
    String countParam, 
    List<String> imagesParam
  }) {
    return Space(
      latlng: latlngParam ?? latlng,
      title: titleParam ?? title,
      description: descriptionParam ?? description,
      count: countParam ?? count,
      images: imagesParam ?? images
    );
  }

  static Object toJson(Space space) {
    return {
      'latlng': space.latlng,
      'title': space.title,
      'description': space.description,
      'count': space.count,
      'images': space.images
    };
  }
}