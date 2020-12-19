import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_test_project/mapScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapScreen(),
    );
  }
}

// class MapSample extends StatefulWidget {
//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample> {
//   GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
//   // Completer<GoogleMapController> _controller = Completer();
//   Marker marker;
//   Circle circle;
//   StreamSubscription _locationSubscription;
//   GoogleMapController _controller;
//   Location _locationTracker = Location();
//   BitmapDescriptor customIcon;
//   String firstName;
//   String lastName;
//   String email;
//   String avatar;

//   @override
//   void initState() {
//     locatedPosition();
//     getHttp();
//     super.initState();
//   }

//   void getHttp() async {
//     try {
//       Response response = await Dio().get("https://reqres.in/api/users/2");
//       print(response.data);
//       print(response.data.length);
//       firstName = response.data['data']['first_name'];
//       lastName = response.data['data']['last_name'];
//       avatar = response.data['data']['avatar'];
//       email = response.data['data']['email'];
//     } catch (e) {
//       print(e);
//     }
//   }

//   showdialog() {
//     return showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             // title: Text('$firstName $lastName'),
//             content: Container(
//               height: 200,
//               child: Column(
//                 children: [
//                   Text('Name : $firstName $lastName'),
//                   Text('Email : $email'),
//                   Card(
//                     child: Image.network(avatar),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     elevation: 5,
//                   ),
//                 ],
//               ),
//             ),
//             actions: <Widget>[
//               FlatButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('Ok'),
//               )
//             ],
//           );
//         });
//   }

//   ///Google map

//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );

//   Future<Uint8List> getMarker() async {
//     ByteData byteData =
//         await DefaultAssetBundle.of(context).load('assets/car.png');
//     return byteData.buffer.asUint8List();
//   }

//   void updateMarkerAndCircle(LocationData position, Uint8List imageData) {
//     LatLng latlag = LatLng(position.latitude, position.longitude);

//     this.setState(() {
//       marker = Marker(
//           markerId: MarkerId('home'),
//           position: latlag,
//           rotation: position.heading,
//           draggable: true,
//           // zIndex: 2,
//           flat: true,
//           icon: BitmapDescriptor.fromBytes(imageData),
//           anchor: Offset(0.5, 0.5),
//           onTap: () {
//             showdialog();
//           });
//     });
//   }

//   GoogleMapController newGoogleMapConnection;

//   Position currentPosition;
//   LatLng latlag;
//   var geoLocation = Geolocator();

//   locatedPosition() async {
//     Uint8List imageData = await getMarker();
//     var location = await _locationTracker.getLocation();

//     updateMarkerAndCircle(location, imageData);

//     if (_locationSubscription != null) {
//       _locationSubscription.cancel();
//     }

//     _locationSubscription =
//         _locationTracker.onLocationChanged.listen((newlocation) {
//       if (_controller != null) {
//         _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//           bearing: 192,
//           target: LatLng(newlocation.latitude, newlocation.longitude),
//           tilt: 0,
//           zoom: 18.00,
//         )));
//         // updateMarkerAndCircle(newlocation);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       body: GoogleMap(
//         markers: Set.of((marker != null) ? [marker] : []),
//         mapType: MapType.hybrid,
//         initialCameraPosition: _kGooglePlex,
//         onMapCreated: (GoogleMapController controller) {
//           _controller = controller;
//           locatedPosition();
//         },
//       ),
//     );
//   }
// }
