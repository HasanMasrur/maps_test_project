import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  // Completer<GoogleMapController> _controller = Completer();
  Marker marker;
  Circle circle;
  StreamSubscription _locationSubscription;
  GoogleMapController _controller;
  Location _locationTracker = Location();
  BitmapDescriptor customIcon;
  String firstName;
  String lastName;
  String email;
  String avatar;
  @override
  void initState() {
    getHttp();
    super.initState();
  }

  void getHttp() async {
    try {
      Response response = await Dio().get("https://reqres.in/api/users/2");
      print(response.data);
      print(response.data.length);
      firstName = response.data['data']['first_name'];
      lastName = response.data['data']['last_name'];
      avatar = response.data['data']['avatar'];
      email = response.data['data']['email'];
    } catch (e) {
      print(e);
    }
  }

  showdialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Text('$firstName $lastName'),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  Text('Name : $firstName $lastName'),
                  Text('Email : $email'),
                  Card(
                    child: Image.asset('assets/car.png'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Ok'),
              )
            ],
          );
        });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load('assets/car.png');
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData position, Uint8List imageData) {
    LatLng latlag = LatLng(position.latitude, position.longitude);

    this.setState(() {
      marker = Marker(
          markerId: MarkerId('home'),
          position: latlag,
          rotation: position.heading,
          draggable: false,
          // zIndex: 2,
          flat: true,
          icon: BitmapDescriptor.fromBytes(imageData),
          anchor: Offset(0.5, 0.5),
          onTap: () {
            showdialog();
          });
    });
  }

  GoogleMapController newGoogleMapConnection;

  Position currentPosition;
  LatLng latlag;
  var geoLocation = Geolocator();

  locatedPosition() async {
    Uint8List imageData = await getMarker();
    var location = await _locationTracker.getLocation();

    updateMarkerAndCircle(location, imageData);

    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }

    _locationSubscription =
        _locationTracker.onLocationChanged.listen((newlocation) {
      if (_controller != null) {
        _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 192,
          target: LatLng(newlocation.latitude, newlocation.longitude),
          tilt: 0,
          zoom: 18.00,
        )));
        // updateMarkerAndCircle(newlocation);
      }
    });
  }

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(23.8103, -90.4125),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    double heights = MediaQuery.of(context).size.height;
    double widths = MediaQuery.of(context).size.width;
    return new Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            markers: Set.of((marker != null) ? [marker] : []),
            mapType: MapType.hybrid,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              locatedPosition();
            },
          ),
          Positioned(
              top: heights * 0.03,
              left: widths * 0.80,
              right: widths * .03,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                height: 50,
                width: 50,
                child: IconButton(
                    icon: Icon(Icons.location_searching, color: Colors.black),
                    onPressed: () {
                      return locatedPosition();
                    }),
              )),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {

      //   },
      //   label: Text('corrent location'),
      //   icon: Icon(Icons.location_searching),
      // ),
    );
  }
}
