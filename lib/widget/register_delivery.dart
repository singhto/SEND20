import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodlion/scaffold/register_shop_success.dart';
import 'package:foodlion/utility/my_constant.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class RegisterDelivery extends StatefulWidget {
  @override
  _RegisterDeliveryState createState() => _RegisterDeliveryState();
}

class _RegisterDeliveryState extends State<RegisterDelivery> {
  // Field
  double lat, lng;
  File file;
  String name, user, password, phone, urlImage;
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
              hintText: 'User :',
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

  Widget phoneForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            onChanged: (value) => phone = value.trim(),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone),
              hintText: 'Phone :',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget cameraButton() {
    return OutlineButton.icon(
      onPressed: () => chooseImage(ImageSource.camera),
      icon: Icon(Icons.add_a_photo),
      label: Text('Camera'),
    );
  }

  Future<void> chooseImage(ImageSource source) async {
    try {
      var object = await ImagePicker()
          .getImage(source: source, maxWidth: 800.0, maxHeight: 800.0);

      setState(() {
        file = File(object.path);
      });
    } catch (e) {}
  }

  Widget galleryButton() {
    return OutlineButton.icon(
      onPressed: () => chooseImage(ImageSource.gallery),
      icon: Icon(Icons.add_photo_alternate),
      label: Text('Gallery'),
    );
  }

  Widget showButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        cameraButton(),
        galleryButton(),
      ],
    );
  }

  Widget showPicture() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: file == null
          ? Image.asset('images/deliveryProfile.png')
          : Image.file(file),
    );
  }

  Widget uploadButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton.icon(
        color: MyStyle().primaryColor,
        onPressed: () {
          if (file == null) {
            normalDialog(
                context, 'Non Choose Image', 'Please Click Camera or Gallery');
          } else if (name == null ||
              name.isEmpty ||
              user == null ||
              user.isEmpty ||
              password == null ||
              password.isEmpty ||
              phone == null ||
              phone.isEmpty) {
            normalDialog(context, 'Have Space', 'Please Fill Every Blank');
          } else {
            checkUser();
          }
        },
        icon: Icon(
          Icons.cloud_upload,
          color: Colors.white,
        ),
        label: Text(
          'บันทึก',
          style: MyStyle().h2StyleWhite,
        ),
      ),
    );
  }

  Future<void> checkUser() async {
    setState(() {
      isLoading = true;
    });
    String url =
        '${MyConstant().urlGetDeliveryWhereUser}?isAdd=true&User=$user';
    try {
      await Dio().get(url).then((response) {
        setState(() {
          isLoading = false;
        });
        if (response.toString() == 'null') {
          uploadImageToServer();
        } else {
          normalDialog(
            context,
            'User ซ้ำ',
            'เปลี่ยน User ใหม่ คะ ? User ซ้ำ',
            icon: MyStyle().signUpIcon,
          );
        }
      });
    } catch (e) {}
  }

  Future<void> uploadImageToServer() async {
    String url = MyConstant().urlSaveFileDelivery;
    Random random = Random();
    int i = random.nextInt(100000);
    String nameFile = 'delivery$i.jpg';
    setState(() {
      isLoading = true;
    });
    try {
      Map<String, dynamic> map = Map();
      // map['file'] = UploadFileInfo(file, nameFile);
      // FormData formData = FormData.from(map);

      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);

      await Dio()
          .post(url, data: formData)
          .then((response) => insertDtaToMySQL(nameFile))
          .catchError(() {});
    } catch (e) {}
  }

  Future<void> insertDtaToMySQL(String string) async {
    urlImage = '${MyConstant().urlImagePatDelivery}$string';
    setState(() {
      isLoading = true;
    });
    String urlAPI =
        '${MyConstant().urlAddDeliveryInfo}?isAdd=true&Name=$name&User=$user&Password=$password&UrlDev=$urlImage&Lat=$lat&Lng=$lng&PhoneDelivery=$phone';

    try {
      await Dio().get(urlAPI).then(
        (response) {
          if (response.toString() == 'true') {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (value) => RegisterShopSuccess(),
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
        showPicture(),
        Center(
            child: Text(
          'ภาพถ่ายหน้าตรง',
          style: MyStyle().h2NormalStyle,
        )),
        showButton(),
        MyStyle().mySizeBox(),
        nameForm(),
        MyStyle().mySizeBox(),
        userForm(),
        MyStyle().mySizeBox(),
        passwordForm(),
        MyStyle().mySizeBox(),
        phoneForm(),
        MyStyle().mySizeBox(),
        Padding(
          padding: EdgeInsets.all(8.0),
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
