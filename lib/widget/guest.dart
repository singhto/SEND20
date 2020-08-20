import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:foodlion/scaffold/home.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Guest extends StatefulWidget {
  @override
  GuestState createState() => GuestState();
}

class GuestState extends State<Guest> {
  double lat;
  double lng;
  double currentLat;
  double currentLng;
  bool serviceLocationEnable;
  Location location = Location();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.751741, 101.215784),
    zoom: 18,
  );

  static final CameraPosition myPosition = CameraPosition(
    target: LatLng(16.751741, 101.215784),
    zoom: 18,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(16.751741, 101.215784),
      tilt: 59.440717697143555,
      zoom: 18);

  Future gotoCurrentPosition() async {
    CameraPosition ps23 = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(16.751741, 101.215784),
        tilt: 59.440717697143555,
        zoom: 18);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(ps23));
  }

  Future<Null> getLocation() async {
    LocationData locationData = await findLocationData();

    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;
    });
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {}
      return null;
    }
  }

  void _add() {
    final MarkerId markerId = MarkerId('1');

    setState(() {
      if (markers.containsKey(markerId)) {
        markers.remove(markerId);
      }
    });

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(currentLat, currentLng),
      infoWindow:
          InfoWindow(title: 'จุดส่งอาหาร', snippet: 'เลื่อนจอเพื่อปักหมุด'),
      onTap: () {},
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 18,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'บริการตำแหน่งถูกปิดไว้',
            style: MyStyle().h3Style,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'กรุณาเปิดใช้บริการตำแหน่งในการตั้งค่า',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '',
                  style: MyStyle().h2NormalStyle,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Home(),
                          ),
                          (route) => false);
                    },
                    //color: Colors.green,
                    child: Text(
                      'ยกเลิก',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 50.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: () {
                  AppSettings.openLocationSettings();
                  setState(() {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Home(),
                        ),
                        (route) => false);
                  });
                },
                //color: Colors.red,
                child: Text('การตั้งค่า',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 20.0,
                    )),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ค้นหาร้านค้า'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onCameraMove: (CameraPosition position) {
              //print(position);
              setState(() {
                currentLat = position.target.latitude;
                currentLng = position.target.longitude;
              });
              _add();
            },
            markers: {},

            //Set<Marker>.of(markers.values),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 10.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.location_searching, color: Colors.white),
                      onPressed: () {
                        AppSettings.openLocationSettings();
                      },
                    ),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.orange),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        _showMyDialog();
                      },
                    ),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
