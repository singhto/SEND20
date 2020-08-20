import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodlion/models/user_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/widget/user_home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestMap extends StatefulWidget {
  final double myLat, myLng;
  GuestMap({Key key, this.myLat, this.myLng}) : super(key: key);
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

  CameraPosition myPosition;

  Future gotoCurrentPosition() async {
    CameraPosition ps23 = CameraPosition(

        target: LatLng(lat, lng),

        zoom: 18);
    print('=====>>>> $lat, $lng');

    double mylat = widget.myLat;
    double mylng = widget.myLng;

    CameraPosition position = CameraPosition(
      target: LatLng(mylat, mylng),
      zoom: 18,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  Future getLocation() async {

    double myLat = widget.myLat;
    double myLng = widget.myLng;

    setState(() {
      lat = myLat;
      lng = myLng;
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
      position: currentLat == null
          ? LatLng(widget.myLat, widget.myLng)
          : LatLng(currentLat, currentLng),
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
        //bearing: 192.8334901395799,
        target: LatLng(currentLat, currentLng),
        //tilt: 59.440717697143555,
        zoom: 18);
    print('=====>>>> $currentLat, $currentLng');

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(ps23));
  }

  Future<Null> insertMapForm() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          'สถานที่จัดส่ง',
          style: MyStyle().h1PrimaryStyle,
        ),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                child: TextField(
                  onChanged: (value) => nameLocation = value.trim(),
                  decoration: InputDecoration(
                    labelText: 'กรุณาตั้งชื่อ เช่น บ้าน/ที่ทำงาน/อื่นๆ :',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.red,
                      width: 200.0,
                    )),
                  ),
                ),
              ),
            ],
          ),
          MyStyle().mySizeBox(),
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
                      Navigator.pop(context);
                      uploadValuToSendLocation();
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text(
                    'บันทึก',
                    style: MyStyle().h2Style,
                  ),
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

    await MyAPI()
        .addSendLocation(
            idUser, currentLat.toString(), currentLng.toString(), nameLocation)
        .then((value) {
      Navigator.pop(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'ขยับหน้าจอเพื่อปักหมุด',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            buildGoogleMap(),
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
                          setState(() {
                            gotoCurrentPosition();
                          });

                          //_add();
                        },
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.green),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Container(
                      child: IconButton(
                        icon: Icon(Icons.save, color: Colors.white),
                        onPressed: () {
                          updateLatLng();
                          //normalToast('พิกัด $lat, $lng สำเร็จ');
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

  GoogleMap buildGoogleMap() {
    if (lat != null) {
      myPosition = CameraPosition(
        target: LatLng(lat, lng),
        zoom: 18,
      );
    }

    Set<Marker> myMarker() {
      return <Marker>[
        Marker(
          markerId: MarkerId('1'),
          position: LatLng(widget.myLat, widget.myLng),
        ),
      ].toSet();
    }

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: myPosition,
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
      markers:
          markers.length == 0 ? myMarker() : Set<Marker>.of(markers.values),
    );
  }
}
