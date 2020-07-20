import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodlion/models/user_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/normal_toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestMap extends StatefulWidget {
  @override
  GuestMapState createState() => GuestMapState();
}

class GuestMapState extends State<GuestMap> {
  double lat;
  double lng;
  double currentLat;
  double currentLng;
  String nameLocation;
  UserModel userModel;

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

  Future gotoCurrentPosition() async {
    CameraPosition ps23 = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(lat, lng),
        tilt: 59.440717697143555,
        zoom: 16);
    print('=====>>>> $lat, $lng');

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

  Future updateLatLng() async {
    CameraPosition ps23 = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(currentLat, currentLng),
        tilt: 59.440717697143555,
        zoom: 16);
    print('=====>>>> $currentLat, $currentLng');

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(ps23));
  }

  Future<Null> insertMapForm() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ที่ส่งใหม่'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                child: TextField(
                  onChanged: (value) => nameLocation = value.trim(),
                  decoration: InputDecoration(
                    labelText: 'ชื่อที่จัดส่ง :',
                    //border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200.0,
                child: RaisedButton.icon(
                  onPressed: () {
                    if (nameLocation == null || nameLocation.isEmpty) {
                      normalDialog(context, 'ยังไม่ใส่ชื่อที่จัดส่ง',
                          'กรุณากำหนดชื่อที่จัดส่ง');
                    } else {
                      uploadValuToSendLocation();
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('บันทึก'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<Null> uploadValuToSendLocation() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String idUser = preferences.getString('id');

    print(
        ' onSave idUser $idUser lat = $currentLat, lng $currentLng , nameLocation $nameLocation,');

    await MyAPI()
        .addSendLocation(idUser, lat.toString(), lng.toString(), nameLocation)
        .then((value) {
          Navigator.pop(context);
        });
  }

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
                          //normalToast('พิกัด $currentLng, $currentLng');
                          insertMapForm();
                        },
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
