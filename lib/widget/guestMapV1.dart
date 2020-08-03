import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/normal_toast.dart';
import 'package:foodlion/widget/guestV1.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GuestMapV1 extends StatefulWidget {
  @override
  GuestMapV1State createState() => GuestMapV1State();
}

class GuestMapV1State extends State<GuestMapV1> {
  double lat;
  double lng;
  double currentLat;
  double currentLng;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.755140, 101.215890),
    zoom: 14.4746,
  );

  static final CameraPosition myPosition = CameraPosition(
    target: LatLng(13.8449339, 100.5793709),
    zoom: 16,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(16.755140, 101.215890),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future gotoCurrentPosition() async {
    CameraPosition ps23 = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(lat, lng),
        tilt: 59.440717697143555,
        zoom: 16);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(ps23));
  }



  Future getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);

    setState(() {
      lat = position.latitude ?? 16.7516811;
      lng = position.longitude ?? 101.215812;
    });
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
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueOrange,
      ),
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

  // Widget _buildContainer() {
  //   return Align(
  //     alignment: Alignment.bottomLeft,
  //     child: Container(
  //       margin: EdgeInsets.symmetric(vertical: 20.0),
  //       height: 150.0,
  //       child: ListView(
  //         scrollDirection: Axis.horizontal,
  //         children: <Widget>[
  //           SizedBox(width: 10.0),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: _boxes("http://movehubs.com/app/Shop/shop22745.jpg",
  //                 16.7547542, 101.2034712, "มนตราอาหารพื้นบ้าน"),
  //           ),
  //           SizedBox(width: 10.0),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: _boxes("http://movehubs.com/app/Shop/shop16647.jpg",
  //                 16.7392659, 101.2441823, "ขนมจีนป้ากุล"),
  //           ),
  //           SizedBox(width: 10.0),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: _boxes("http://movehubs.com/app/Shop/shop39029.jpg",
  //                 16.7813229, 101.248375, "ออนซอน"),
  //           ),
  //           SizedBox(width: 10.0),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: _boxes("http://movehubs.com/app/Shop/shop49995.jpg",
  //                 16.7538612, 101.2076809, "ผัดไทยเจ้าจอม"),
  //           ),
  //           SizedBox(width: 10.0),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: _boxes("http://movehubs.com/app/Shop/shop7328.jpg",
  //                 16.7519874, 101.2079435, "มารุชาสาขาพ่อขุน"),
  //           ),
  //           SizedBox(width: 10.0),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: _boxes("http://movehubs.com/app/Shop/shop31283.jpg",
  //                 16.7539499, 101.2100508, "เจ๊กุ้งอาหารตามสั่ง"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _boxes(String _image, double lat, double lng, String restaurantName) {
  //   return GestureDetector(
  //     onTap: () {
  //       _gotoLocation(lat, lng);
  //     },
  //     child: Container(
  //       child: new FittedBox(
  //         child: Material(
  //             color: Colors.white,
  //             elevation: 14.0,
  //             borderRadius: BorderRadius.circular(24.0),
  //             shadowColor: Color(0x802196F3),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: <Widget>[
  //                 Container(
  //                   width: 180,
  //                   height: 200,
  //                   child: ClipRRect(
  //                     borderRadius: new BorderRadius.circular(24.0),
  //                     child: Image(
  //                       fit: BoxFit.cover,
  //                       image: NetworkImage(_image),
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: myDetailsContainer1(restaurantName),
  //                   ),
  //                 ),
  //               ],
  //             )),
  //       ),
  //     ),
  //   );
  // }

  // Widget myDetailsContainer1(String restaurantName) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: <Widget>[
  //       Padding(
  //         padding: const EdgeInsets.only(left: 8.0),
  //         child: Container(
  //             child: Text(
  //           restaurantName,
  //           style: TextStyle(
  //               color: Color(0xff6200ee),
  //               fontSize: 24.0,
  //               fontWeight: FontWeight.bold),
  //         )),
  //       ),
  //       SizedBox(height: 5.0),
  //       Container(
  //           child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: <Widget>[
  //           Container(
  //             child: Icon(
  //               FontAwesomeIcons.solidStar,
  //               color: Colors.amber,
  //               size: 15.0,
  //             ),
  //           ),
  //           Container(
  //             child: Icon(
  //               FontAwesomeIcons.solidStar,
  //               color: Colors.amber,
  //               size: 15.0,
  //             ),
  //           ),
  //           Container(
  //             child: Icon(
  //               FontAwesomeIcons.solidStar,
  //               color: Colors.amber,
  //               size: 15.0,
  //             ),
  //           ),
  //           Container(
  //             child: Icon(
  //               FontAwesomeIcons.solidStar,
  //               color: Colors.amber,
  //               size: 15.0,
  //             ),
  //           ),
  //           Container(
  //             child: Icon(
  //               FontAwesomeIcons.solidStar,
  //               color: Colors.amber,
  //               size: 15.0,
  //             ),
  //           ),
  //           Container(
  //               child: Text(
  //             "(0)",
  //             style: TextStyle(
  //               color: Colors.black54,
  //               fontSize: 18.0,
  //             ),
  //           )),
  //         ],
  //       )),
  //       SizedBox(height: 5.0),
  //       Container(
  //           child: Text(
  //         "หล่มสัก",
  //         style: TextStyle(
  //           color: Colors.black54,
  //           fontSize: 18.0,
  //         ),
  //       )),
  //       SizedBox(height: 5.0),
  //       Container(
  //         child: Text(
  //           "โดยเร็วนี้...",
  //           style: TextStyle(
  //               color: Colors.black54,
  //               fontSize: 18.0,
  //               fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //       RaisedButton(
  //           child: Text('ไปที่ร้าน', style: TextStyle(fontSize: 16)),
  //           onPressed: () {
  //             normalDialog(context, 'เปิดทำการ 23 ก.ค.นี้ครับ',
  //                 'โหลดแอพ SEND อีกครั้งหลังเปิดทำการ เพื่อใช้งาน ขอบคุณครับ');
  //           })
  //     ],
  //   );
  // }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }

  Future updateLatLng() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('เลื่อนหน้าจอเพื่อปักหมุด'),
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
                print(position);
                setState(() {
                  currentLat = position.target.latitude;
                  currentLng = position.target.longitude;
                });
                _add();
              },

              markers: Set<Marker>.of(markers.values),

              // {
              //   newyork1Marker,
              //   newyork2Marker,
              //   newyork3Marker,
              //   gramercyMarker,
              //   bernardinMarker,
              //   blueMarker
              // },

              //Set<Marker>.of(markers.values),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 10.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      child: IconButton(
                        icon:
                            Icon(Icons.location_searching, color: Colors.white),
                        onPressed: () {
                          gotoCurrentPosition();
                          _add();
                          normalToast('ตำแหน่งปัจจุบัน');
                        },
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.green),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                      child: IconButton(
                        icon: Icon(Icons.save, color: Colors.white),
                        onPressed: () {
                          updateLatLng();
                        },
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            //_buildContainer(),
          ],
        ));
  }
}

// Marker gramercyMarker = Marker(
//   markerId: MarkerId('มนตราอาหารพื้นบ้าน'),
//   position: LatLng(16.7547542, 101.2034712),
//   infoWindow: InfoWindow(title: 'มนตราอาหารพื้นบ้าน'),
//   icon: BitmapDescriptor.defaultMarkerWithHue(
//     BitmapDescriptor.hueOrange,
//   ),
// );

// Marker bernardinMarker = Marker(
//   markerId: MarkerId('ผัดไทยเจ้าจอม'),
//   position: LatLng(16.7538612, 101.2076809),
//   infoWindow: InfoWindow(title: 'ผัดไทยเจ้าจอม'),
//   icon: BitmapDescriptor.defaultMarkerWithHue(
//     BitmapDescriptor.hueOrange,
//   ),
// );

// Marker blueMarker = Marker(
//   markerId: MarkerId('ออนซอน'),
//   position: LatLng(16.7813229, 101.248375),
//   infoWindow: InfoWindow(title: 'ออนซอน'),
//   icon: BitmapDescriptor.defaultMarkerWithHue(
//     BitmapDescriptor.hueOrange,
//   ),
// );

// //New York Marker

// Marker newyork1Marker = Marker(
//   markerId: MarkerId('ขนมจีนป้ากุล'),
//   position: LatLng(16.7392659, 101.2441823),
//   infoWindow: InfoWindow(title: 'ขนมจีนป้ากุล'),
//   icon: BitmapDescriptor.defaultMarkerWithHue(
//     BitmapDescriptor.hueOrange,
//   ),
// );
// Marker newyork2Marker = Marker(
//   markerId: MarkerId('มารุชาสาขาพ่อขุน'),
//   position: LatLng(16.7519874, 101.2079435),
//   infoWindow: InfoWindow(title: 'มารุชาสาขาพ่อขุน'),
//   icon: BitmapDescriptor.defaultMarkerWithHue(
//     BitmapDescriptor.hueOrange,
//   ),
// );
// Marker newyork3Marker = Marker(
//   markerId: MarkerId('เจ๊กุ้งอาหารตามสั่ง'),
//   position: LatLng(16.7539499, 101.2100508),
//   infoWindow: InfoWindow(title: 'เจ๊กุ้งอาหารตามสั่ง'),
//   icon: BitmapDescriptor.defaultMarkerWithHue(
//     BitmapDescriptor.hueOrange,
//   ),
// );
