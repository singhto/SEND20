import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Guest extends StatefulWidget {
  @override
  _GuestState createState() => _GuestState();
}

class _GuestState extends State<Guest> {
  Completer<GoogleMapController> _controller = Completer();
  LocationData currentLocation;

  Future _goToMe() async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 16,
        ),
      ),
    );
  }

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        //Permission denied
      }
      return null;
    }
  }

  Marker oneMarker = Marker(
  markerId: MarkerId('oneMarker'),
  position: LatLng(16.761048, 101.216276),
  infoWindow: InfoWindow(title: 'การไฟฟ้าฯหล่มสัก'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);
  Marker twoMarker = Marker(
  markerId: MarkerId('oneMarker'),
  position: LatLng(16.742565, 101.222816),
  infoWindow: InfoWindow(title: 'ปตท.โนนทอง'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(16.751421, 101.215739),
            zoom: 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: {
            oneMarker,twoMarker
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Center(
            child: FloatingActionButton.extended(
              onPressed: _goToMe,
              label: Text('ตำแหน่งปัจจุบัน'),
              icon: Icon(Icons.location_searching),
            ),
          ),
        ],
      ),
    );
  }
}
