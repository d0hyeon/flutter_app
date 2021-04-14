import 'dart:async';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_app/constants/map.dart';
import 'package:my_app/models/space.dart';
import 'package:my_app/screens/work_out_result.dart';
import 'package:my_app/utils/google_map.dart';
import 'package:my_app/utils/location.dart';
import 'package:my_app/widgets/space_marker.dart';
import 'package:widget_to_image/widget_to_image.dart';

enum WorkoutState { base, walk, pause, done }
const String USER_MARKER_NAME = 'user_marker';
const String USER_POLYLINE_NAME = 'user_polyline';
const Duration USER_CONTROL_SCREEN_DURATION = Duration(seconds: 10);
const Duration USER_PAUSE_WORKING_DURATION = Duration(seconds: 10);
const double DEFAULT_ZOOM = 18;

List<Space> mock_spaces = [
  Space(
    latlng: LatLng(37.624174, 127.092125),
    title: '화랑대 폐역',
    count: 231,
  ),
  Space(
    latlng: LatLng(37.6231, 127.0803),
    title: '뚜레주르',
    count: 5
  )
];

void backgroundWorkoutLoaction (SendPort mainPort) {
  ReceivePort backgroundPort = ReceivePort();
  StreamSubscription messageStream;
  StreamSubscription locationStream;
  WorkoutState beforeWorkoutState = WorkoutState.base;
  
  mainPort.send(backgroundPort.sendPort);
  messageStream = backgroundPort.listen((message) {
    if(message is WorkoutState) {
      switch(message) {
        case WorkoutState.walk: {
          if(beforeWorkoutState == WorkoutState.pause) {
            locationStream.resume();  
          } else {
            locationStream = Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.best,
              intervalDuration: Duration(seconds: 2)
            ).listen((Position position) {
              mainPort.send(position);
            });
          }
          break;
        }
        case WorkoutState.pause: {
          locationStream.pause();
          break;
        }
        case WorkoutState.done: {
          locationStream.cancel();
          messageStream.cancel();
          backgroundPort.close();
          break;
        }
        default: {

        }
      }
      beforeWorkoutState = message;
    }
  });
}

class Workout extends StatefulWidget {
  static String routeName = '/work_out';
  @override
  _WorkoutState createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  final ReceivePort mainPort = ReceivePort();
  SendPort backgroundPort;
  Isolate backgroundIsolate;
  // 위젯 컨트롤 관련 변수
  final Completer<GoogleMapController> _completer = Completer();
  GoogleMapController _controller;
  bool isUserControl = false;
  bool isPause = false;
  WorkoutState workoutState = WorkoutState.base;
  MapLocationState locationState = MapLocationState.dynamic;

  // 지속적인 변수
  Set<Timer> timers = {};
  StreamSubscription<Position> _locationStream;
  StreamSubscription backgroundMessageStream;

  // 위치정보 관련 변수
  Position mapPosition;
  Position currentPosition;
  Set<Position> routes = {};

  // 구글맵 프로퍼티 변수
  Polyline polyline = Polyline(
    polylineId: PolylineId(USER_POLYLINE_NAME),
    color: Colors.red[600],
    width: 3,
    startCap: Cap.buttCap,
    endCap: Cap.squareCap,
  );
  Marker userMarker = Marker(markerId: MarkerId(USER_MARKER_NAME), visible: false);
  Set<Marker> spaceMarkers = Set();

  void setUserMarkerPosition(Position position) async {
    currentPosition = position;
    BitmapDescriptor icon = userMarker.icon ?? await createUserMarkerIcon();
    setState(() {
      userMarker = userMarker.copyWith(
          positionParam: LatLng(position.latitude, position.longitude),
          visibleParam: true,
          iconParam: icon
        );
    });
  }

  void setCameraPosition(Position position,
      {double zoom = DEFAULT_ZOOM, tilt = DEFAULT_TILT}) {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      tilt: tilt,
      zoom: zoom,
    );
    mapPosition = position;
    _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void setWorkoutState(WorkoutState state) {
    setState(() {
      switch (state) {
        case WorkoutState.walk:
          {
            backgroundPort.send(WorkoutState.walk); 
            runDrawPolyline();
            break;
          }
        case WorkoutState.pause:
          {
            backgroundPort.send(WorkoutState.pause);
            clearTimers();
            break;
          }
        case WorkoutState.done:
          {
            backgroundPort.send(WorkoutState.done);
            // Navigator.popAndPushNamed(context, '/work_out_result')
            Navigator.pushNamed(context, '/work_out_result', arguments: WorkoutResultArguments(
              routes: routes
            ));
            break;
          }
        default:
          {
            break;
          }
      }
      workoutState = state;
    });
  }

  void setCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();

    setCameraPosition(position);
    setUserMarkerPosition(position);
  }
  
  void clearTimers() {
    timers.forEach((timer) {
      timer.cancel();
    });
    timers = {};
  }

  Future<void> createIsolsate () async {
    Timer blockingTimer;

    backgroundMessageStream = mainPort.listen((message) {
      if(message is SendPort) {
        backgroundPort = message;
      } else {
        Position position = message;
        setUserMarkerPosition(position);

        if (position.speed > 0.01) {
          // double diffLat = currentPosition.latitude - position.latitude;
          // double diffLng = currentPosition.longitude - position.longitude;

          // if (diffLat.abs() > 0.000015 || diffLng.abs() > 0.000015) {
          //   currentPosition = position;
          // }

          if (isUserControl) {
            // 사용자 의지로 지도를 이동하였는데, 자동으로 현재 위치로 다시 돌리면 불편함을 제공하기 때문에
            // 사용자의 마지막 터치 이후 10초 뒤에 현재위치로 다시 돌아오도록 함
            locationState = MapLocationState.static;
            blockingTimer?.cancel();
            return blockingTimer = new Timer(USER_CONTROL_SCREEN_DURATION, () {
              locationState = MapLocationState.dynamic;
            });
          }

          if (locationState == MapLocationState.dynamic) {
            setCameraPosition(position);
          }
        }
      }
    });

    backgroundIsolate = await Isolate.spawn(backgroundWorkoutLoaction, mainPort.sendPort);
  }

  void runDrawPolyline() {
    List<Position> currentRoutes = [];

    timers.add(
      Timer.periodic(Duration(seconds: 10), (timer) { 
        setState(() {
          if(currentRoutes.isNotEmpty) {
            polyline = polyline.copyWith(
              pointsParam: [
                ...polyline.points.toList(),
                ...(
                  currentRoutes.map((route) => LatLng(route.latitude, route.longitude))
                )
              ]
            );
            routes.addAll(currentRoutes);
            currentRoutes.clear();
          }
        });
      })
    );

    timers.add(
      Timer.periodic(Duration(seconds: 2), (timer) {
        currentRoutes.add(currentPosition);
        // Position prevRoutesPosition = currentRoutes[currentRoutes.length-1];
        // if(
        //   currentRoutes.isEmpty || (
        //     prevRoutesPosition.latitude != currentPosition.latitude &&
        //     prevRoutesPosition.longitude != currentPosition.longitude
        //   )
        // ) {
        //   currentRoutes.add(currentPosition);
        // }
      })
    );
  }

  void addSpaceMarkers () async {
    Set<Marker> markers = Set();
    Future.forEach(mock_spaces, (Space space) async {
      ByteData markerByteData = await WidgetToImage.widgetToImage(SpaceMarker(
        Text(
          space.count.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 45
          ),
          textDirection: TextDirection.ltr,
        ),
      ));
      
      Marker marker = Marker(
        markerId: MarkerId(space.title),
        position: space.latlng,
        icon: BitmapDescriptor.fromBytes(markerByteData.buffer.asUint8List()),
        infoWindow: InfoWindow(
          title: space.title,
          snippet: space.description
        )
      );
      markers.add(marker);
    }).then((_) {
      setState(() {
        spaceMarkers.addAll(markers);
      });
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    bool serviceEnabled = await requestLocationService();
    if (!serviceEnabled) {
      Navigator.pop(context);
    }
    setCurrentLocation();
    createIsolsate();
  }

  @override
  void dispose() {
    super.dispose();
    clearTimers();
    mainPort.close();
    backgroundIsolate.kill();
    backgroundMessageStream.cancel();
  }
 
  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = Set();
    markers.add(userMarker);
    if(spaceMarkers.isNotEmpty) {
      markers.addAll(spaceMarkers);
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Workout'),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: addSpaceMarkers ,
          child: Icon(Icons.add_location_outlined),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 10,
              child: Stack(
                children: [
                  Listener(
                      onPointerDown: (_) {
                        isUserControl = true;
                      },
                      onPointerUp: (_) {
                        isUserControl = false;
                      },
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: INITIAL_CAMERA_POSITION,
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                          _completer.complete(controller);
                        },
                        markers: markers,
                        polylines: {polyline},
                        compassEnabled: true,
                        myLocationButtonEnabled: true,
                      )),
                  Positioned(
                      right: 10,
                      top: 10,
                      child: Column(
                        children: [
                          MaterialButton(
                            child: Icon(Icons.gps_fixed,
                                color: Colors.black, size: 20),
                            shape: CircleBorder(),
                            color: Colors.white,
                            height: 35,
                            minWidth: 35,
                            
                            onPressed: setCurrentLocation,
                          ),
                        ],
                      )),
                ],
              ),
            ),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 5),
                              child: RawMaterialButton(
                                constraints: BoxConstraints(
                                  minHeight: 40,
                                ),
                                fillColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                child: Text(
                                    workoutState == WorkoutState.base
                                        ? '시작'
                                        : '종료',
                                    style: TextStyle(
                                      color: Colors.black,
                                    )),
                                onPressed: () {
                                  setWorkoutState(
                                      workoutState == WorkoutState.base
                                          ? WorkoutState.walk
                                          : WorkoutState.done);
                                },
                              ))),
                      workoutState == WorkoutState.walk || workoutState == WorkoutState.pause
                        ? Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 5),
                                child: RawMaterialButton(
                                  constraints: BoxConstraints(
                                    minHeight: 40,
                                  ),
                                  fillColor: Colors.grey[800],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.white60),
                                  ),
                                  child: Text(
                                      workoutState == WorkoutState.walk
                                          ? '일시중지'
                                          : '재시작',
                                      style: TextStyle(
                                        color: Colors.white,
                                      )),
                                  onPressed: () {
                                    setWorkoutState(
                                        workoutState == WorkoutState.walk
                                            ? WorkoutState.pause
                                            : WorkoutState.walk);
                                  },
                                )))
                        : SizedBox.shrink()
                    ],
                  ),
                ))
          ],
        ));
  }
}
