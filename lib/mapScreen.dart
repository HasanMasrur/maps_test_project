import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_test_project/model.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Uint8List imageData;
  double _compas = 90;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      permission = await Geolocator.requestPermission();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever &&
        permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  //Get asset image as Unit8List type
  Future<Uint8List> getMarkerImage() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load('assets/car.png');
    return byteData.buffer.asUint8List();
  }

  //Build Car Marker for google map
  Marker _marker(Position position) {
    return Marker(
        markerId: MarkerId('home'),
        position: LatLng(position.latitude, position.longitude),
        rotation: _compas,
        draggable: true,
        // zIndex: 2,
        flat: true,
        icon: BitmapDescriptor.fromBytes(imageData),
        anchor: Offset(0.5, 0.5),
        onTap: () {
          _showDialog();
        });
  }

  //Build Camera possition
  CameraPosition _cameraPosition(double lat, double lng) {
    return CameraPosition(
      target: LatLng(lat, lng),
      zoom: 18.40,
    );
  }

  //Build Google Map
  Widget _buildMap(Position position) {
    return GoogleMap(
      mapType: MapType.hybrid,
      markers: Set.of((_marker(position) != null) ? [_marker(position)] : []),
      initialCameraPosition:
          _cameraPosition(position.latitude, position.longitude),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  _buildErrorWidget(AsyncSnapshot snapshot) {
    return <Widget>[
      Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 60,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text('Error: ${snapshot.error}'),
      )
    ];
  }

  _buildLoadingWidget() {
    return <Widget>[
      SizedBox(
        child: CircularProgressIndicator(),
        width: 60,
        height: 60,
      ),
      const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Awaiting result...'),
      )
    ];
  }

  Future<Person> _fetchData() async {
    Response response;
    Person person;
    try {
      response = await Dio().get("https://reqres.in/api/users/2");
      if (response.statusCode == 200) {
        person = Person.fromJson(response.data['data']);
      }
    } catch (e) {
      print(e);
    }
    return person;
  }

  _showDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.only(top: 150, bottom: 150),
            height: MediaQuery.of(context).size.height * .0,
            child: AlertDialog(
              title: Text('Profile'),
              content: FutureBuilder(
                future: _fetchData(),
                builder:
                    (BuildContext context, AsyncSnapshot<Person> snapshot) {
                  Widget content = Container();
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      content = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name : ' +
                              snapshot.data.firstName +
                              ' ' +
                              snapshot.data.lastName),
                          Text('Email : ' + snapshot.data.email),
                          Card(
                            child: Image.network(snapshot.data.avater),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5,
                          ),
                        ],
                      );
                    }
                  }

                  if (snapshot.hasError) {
                    content = Center(
                      child: Text('Something Went wrong!'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    content = Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return content;
                },
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'))
              ],
            ),
          );
        });
  }

  void _streamListener(double currentHeading) {
    setState(() {
      //we set the new heading value to our _compas variable to display on screen
      _compas = currentHeading;
    });
  }

  @override
  void didChangeDependencies() async {
    imageData = await getMarkerImage();
    // _simpleFlutterCompass.check().then((result) {
    //   if (result) {
    //     _simpleFlutterCompass.setListener(_streamListener);
    //   } else {
    //     print("Hardware not available");
    //   }
    // });
    // _simpleFlutterCompass.listen();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
        centerTitle: true,
      ),
      body: Container(
        child: FutureBuilder<Position>(
          future: _determinePosition(),
          builder: (context, AsyncSnapshot<Position> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              return _buildMap(snapshot.data);
            } else if (snapshot.hasError) {
              children = _buildErrorWidget(snapshot);
            } else {
              children = _buildLoadingWidget();
            }
            return Center(
              child: Column(
                children: children,
              ),
            );
          },
        ),
      ),
    );
  }
}
