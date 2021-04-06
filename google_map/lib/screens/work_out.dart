import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_app/constants/map.dart';
import 'package:my_app/screens/work_out_result.dart';
import 'package:my_app/utils/google_map.dart';
import 'package:my_app/utils/location.dart';

enum WorkoutState { base, walk, pause, done }
const String USER_MARKER_NAME = 'user_marker';
const String USER_POLYLINE_NAME = 'user_polyline';
const Duration USER_CONTROL_SCREEN_DURATION = Duration(seconds: 10);
const Duration USER_PAUSE_WORKING_DURATION = Duration(seconds: 10);
const double DEFAULT_ZOOM = 18;

class Workout extends StatefulWidget {
  static String routeName = '/work_out';
  @override
  _WorkoutState createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  // 위젯 컨트롤 관련 변수
  final Completer<GoogleMapController> _completer = Completer();
  GoogleMapController _controller;
  bool isUserControl = false;
  bool isPause = false;
  WorkoutState workoutState = WorkoutState.base;

  // 지속적인 변수
  Set<Timer> timers = {};
  StreamSubscription<Position> _locationStream;

  // 위치정보 관련 변수
  Position lastPosition;
  Set<Position> routes = {};

  // 구글맵 프로퍼티 변수
  Polyline polyline = Polyline(
    polylineId: PolylineId(USER_POLYLINE_NAME),
    color: Colors.red[600],
    width: 3,
    startCap: Cap.buttCap,
    endCap: Cap.squareCap,
  );
  Marker marker = Marker(markerId: MarkerId(USER_MARKER_NAME), visible: false);

  void setMarkerPosition(Position position) async {
    BitmapDescriptor icon = await createUserMarkerIcon();
    setState(() {
      marker = marker.copyWith(
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
    lastPosition = position;
    _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void setWorkoutState(WorkoutState state) {
    setState(() {
      switch (state) {
        case WorkoutState.walk:
          {
            subscribeLocationStream();
            break;
          }
        case WorkoutState.pause:
          {
            cancelStreams();
            break;
          }
        case WorkoutState.done:
          {
            cancelStreams();
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
    setMarkerPosition(position);
  }
  
  void cancelStreams () {
    _locationStream?.cancel();
    timers.forEach((timer) {
      timer.cancel();
    });
    timers = {};
  }

  void subscribeLocationStream() async {
    Timer timer;
    Position currPosition = lastPosition;
    List<Position> currRoutes = [];
    MapLocationState locationState = MapLocationState.dynamic;

    timers.add(
      Timer.periodic(Duration(seconds: 10), (timer) {
        setState(() {
          if(currRoutes.isNotEmpty) {
            polyline = polyline.copyWith(
              pointsParam: [
                ...polyline.points.toList(),
                ...(
                  currRoutes.map((route) => LatLng(route.latitude, route.longitude)).toList()
                )
              ]
            );
            routes.addAll(currRoutes);
            currRoutes = [];
          }
        });
      })
    );

    timers.add(
      Timer.periodic(Duration(seconds: 1), (_) {
        currRoutes.add(currPosition);
      })
    );

    _locationStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.best,
            intervalDuration: Duration(seconds: 2))
        .listen((Position position) async {
      setMarkerPosition(position);

      if (position.speed > 0.01) {
        double diffLat = lastPosition.latitude - position.latitude;
        double diffLng = lastPosition.longitude - position.longitude;

        if (diffLat.abs() > 0.000015 || diffLng.abs() > 0.000015) {
          currPosition = position;
        }

        if (isUserControl) {
          // 사용자 의지로 지도를 이동하였는데, 자동으로 현재 위치로 다시 돌리면 불편함을 제공하기 때문에
          // 사용자의 마지막 터치 이후 10초 뒤에 현재위치로 다시 돌아오도록 함
          locationState = MapLocationState.static;
          timer?.cancel();
          return timer = new Timer(USER_CONTROL_SCREEN_DURATION, () {
            locationState = MapLocationState.dynamic;
          });
        }

        if (locationState == MapLocationState.dynamic) {
          setCameraPosition(position);
        }
      }
    });
  }

  @override
  void didChangeDependencies() async {
    bool serviceEnabled = await requestLocationService();
    if (!serviceEnabled) {
      Navigator.pop(context);
    }
    setCurrentLocation();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    cancelStreams();
  }
 
  @override
  Widget build(BuildContext context) {
    print('polylinepolylinepolylinepolyline');
    print(polyline.points);
    return Scaffold(
        appBar: AppBar(
          title: Text('Workout'),
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
                        markers: {marker},
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
