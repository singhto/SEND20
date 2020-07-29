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
import 'package:foodlion/widget/signin_user.dart';
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
      if (e.code == 'PERMISSION_DENIED') {}
      return null;
    }
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
    String urlAPI =
        'http://movehubs.com/app/addUser.php?isAdd=true&Name=$name&User=$user&Password=$password&Token=$token&Lat=$lat&Lng=$lng';

    try {
      await Dio().get(urlAPI).then(
        (response) {
          //print('res==>>>$response');
          if (response.toString() == 'true') {
            normalToast('สมัครสำเร็จ กรุณาลงชื่อเข้าใช้อีกครั้ง..');
            MaterialPageRoute route = MaterialPageRoute(
              builder: (value) => SingInUser(),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (value) => false);
          } else {
            normalDialog(context, 'เกิดข้อผิดพลาด', 'กรุณาลองใหม่');
          }
        },
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   title: Text('สมัครใช้บริการ'),
      // ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              MyStyle().mySizeBox(),
              Text(
                'ข้อมูลของคุณ',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 34.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5.0,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: TextField(
                  onChanged: (value) => name = value.trim(),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'ชื่อ - นามสกุล',
                      prefixIcon: Icon(
                        Icons.account_box,
                        size: 30.0,
                      )),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: TextField(
                  onChanged: (value) => user = value.trim(),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Email / Phone',
                      prefixIcon: Icon(
                        Icons.email,
                        size: 30.0,
                      )),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: TextField(
                  onChanged: (value) => password = value.trim(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock,
                      size: 30.0,
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: isLoading ? MyStyle().showProgress() : null,
              ),
              GestureDetector(
                onTap: () {
                  if (name == null ||
                      name.isEmpty ||
                      user == null ||
                      user.isEmpty ||
                      password == null ||
                      password.isEmpty) {
                    normalDialog(context, 'ห้ามเว้นว่าง',
                        'กรุณากรอกข้อมูลให้ครบทุกช่อง');
                  } else {
                    checkUser();
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 60.0),
                  alignment: Alignment.center,
                  height: 45.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(
                    'สมัครใช้บริการ',
                    style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
