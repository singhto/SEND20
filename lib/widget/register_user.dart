import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodlion/scaffold/home.dart';
import 'package:foodlion/utility/my_constant.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/normal_toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class RegisterUser extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  // Field
  double lat, lng;
  File file;
  String name, user, password, phone, urlImage, token = 'token';
  bool isLoading = false;

  // Method

  @override
  void initState() {
    super.initState();
    findLocation();
  }

  Future<void> findLocation() async {
    LocationData myData = await locationData();
    setState(() {
      lat = myData.latitude;
      lng = myData.longitude;
    });
  }

  Future<LocationData> locationData() async {
    var location = Location();

    try {
      return await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        
      }
      return null;
    }
  }

  Widget showMap() {
    LatLng centerLatLng = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(
      target: centerLatLng,
      zoom: 16.0,
    );

    return GoogleMap(
      initialCameraPosition: cameraPosition,
      markers: myMarkers(),
      onMapCreated: (value) {},
    );
  }

  Set<Marker> myMarkers() {
    LatLng latLng = LatLng(lat, lng);

    return <Marker>[
      Marker(
        markerId: MarkerId('idShop'),
        position: latLng,
        infoWindow: InfoWindow(
          title: 'Your',
          snippet: 'lat = $lat, lng = $lng',
        ),
      ),
    ].toSet();
  }

  Widget nameForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            onChanged: (value) => name = value.trim(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.account_box),
              hintText: 'ชื่อ-นามสกุล :',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget userForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            onChanged: (value) => user = value.trim(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email),
              hintText: 'Username :',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget passwordForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            onChanged: (value) => password = value.trim(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_open),
              hintText: 'Password :',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget uploadButton() {
    return Column(
      children: <Widget>[
        Material(
          borderRadius: BorderRadius.all(
            const Radius.circular(30.0),
          ),
          shadowColor: Theme.of(context).primaryColor,
          elevation: 5.0,
          child: MaterialButton(
            onPressed: () {
              if (name == null ||
                  name.isEmpty ||
                  user == null ||
                  user.isEmpty ||
                  password == null ||
                  password.isEmpty) {
                normalDialog(context, 'ห้ามเว้นว่าง', 'กรุณากรอกข้อมูลให้ครบทุกช่อง');
              } else {
                checkUser();
              }
            },
            color: Theme.of(context).primaryColor,
            minWidth: 250.0,
            height: 55.0,
            child: Text('สมัครใช้บริการ', style: TextStyle(
              color: Colors.white,
              fontSize: 25.0,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.3,
            ),),
          ),
        ),
      ],
    );
  }

  Future<void> checkUser() async {
    setState(() {
      isLoading = true;
    });
    String url = '${MyConstant().urlGetUserWhereUser}?isAdd=true&User=$user';
    try {
      await Dio().get(url).then((response) {
        setState(() {
          isLoading = false;
        });
        if (response.toString() == 'null') {
          insertDtaToMySQL();
        } else {
          normalDialog(
            context,
            'Username ซ้ำ',
            'เปลี่ยน User ใหม่ คะ ? User ซ้ำ',
            icon: MyStyle().signUpIcon,
          );
        }
      });
    } catch (e) {
      insertDtaToMySQL();
    }
  }

  Future<void> uploadImageToServer() async {
    String url = MyConstant().urlSaveFileUser;
    Random random = Random();
    int i = random.nextInt(100000);
    String nameFile = 'user$i.jpg';

    try {
      Map<String, dynamic> map = Map();
      // map['file'] = UploadFileInfo(file, nameFile);
      // FormData formData = FormData.from(map);
      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);
      await Dio()
          .post(url, data: formData)
          .then((response) {})
          .catchError(() {});
    } catch (e) {}
  }

  Future<void> insertDtaToMySQL() async {
    setState(() {
      isLoading = true;
    });
    String urlAPI ='http://movehubs.com/app/addUser.php?isAdd=true&Name=$name&User=$user&Password=$password&Token=$token&Lat=$lat&Lng=$lng';

    try {
      await Dio().get(urlAPI).then(
        (response) {
          //print('res==>>>$response');
          if (response.toString() == 'true') {
            normalToast('สมัครสำเร็จ กรุณาลงชื่อเข้าใช้อีกครั้ง..');
            MaterialPageRoute route = MaterialPageRoute(
              builder: (value) => Home(),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (value) => false);
          } else {
            normalDialog(context, 'เกิดข้อผิดพลาด', 'กรุณาลองใหม่');
          }
        },
      );
    } catch (e) {}
  }

  Widget showListView() {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: <Widget>[
        MyStyle().mySizeBox(),
        nameForm(),
        MyStyle().mySizeBox(),
        userForm(),
        MyStyle().mySizeBox(),
        passwordForm(),
        MyStyle().mySizeBox(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading ? MyStyle().showProgress() : null,
        ),
        uploadButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return showListView();
  }
}
